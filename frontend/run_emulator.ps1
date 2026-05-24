# Emülatör + Flutter (Android)
# Not: adb PATH'te yoksa tam yol kullanilir.
# Cold boot (snapshot kapali): .\run_emulator.ps1 -ColdBoot

param(
    [switch]$ColdBoot
)

$sdk = "$env:LOCALAPPDATA\Android\Sdk"
$adb = "$sdk\platform-tools\adb.exe"
$emulator = "$sdk\emulator\emulator.exe"
$minFreeGb = 5

function Get-FreeGb($path = "C:") {
    $drive = Get-PSDrive ($path.TrimEnd(':')) -ErrorAction SilentlyContinue
    if (-not $drive) { return 0 }
    return [math]::Round($drive.Free / 1GB, 2)
}

function Clear-StaleEmulatorLock {
    $lock = "$env:USERPROFILE\.android\avd\Pixel6.avd\hardware-qemu.ini.lock"
    if (-not (Test-Path $lock)) { return }

    $pidFile = Join-Path $lock "pid"
    if (Test-Path $pidFile) {
        $oldPid = Get-Content $pidFile -ErrorAction SilentlyContinue
        if ($oldPid -and -not (Get-Process -Id $oldPid -ErrorAction SilentlyContinue)) {
            Remove-Item $lock -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Eski emulator lock temizlendi."
        }
    }
}

function Set-EmulatorWindowCenter {
    param(
        [string]$AvdName = "Pixel6",
        [double]$Scale = 0.75
    )

    $iniPath = "$env:USERPROFILE\.android\avd\$AvdName.avd\emulator-user.ini"
    $avdDir = Split-Path $iniPath -Parent
    if (-not (Test-Path $avdDir)) { return }

    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue | Out-Null
    $work = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $emuW = [int](440 * $Scale)
    $emuH = [int](900 * $Scale)
    $x = $work.X + [Math]::Max(20, [int](($work.Width - $emuW) / 2))
    $y = $work.Y + [Math]::Max(60, [int](($work.Height - $emuH) / 2))

    @(
        "window.x = $x"
        "window.y = $y"
        "window.scale = $Scale"
        "resizable.config.id = -1"
        "posture = 0"
    ) | Set-Content -Path $iniPath -Encoding ascii

    Write-Host "Emulator konumu kaydedildi (${x}, ${y})."
}

function Move-EmulatorWindowToCenter {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue | Out-Null
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class EmulatorWinApi {
    [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out EmuRect r);
    [StructLayout(LayoutKind.Sequential)]
    public struct EmuRect { public int Left, Top, Right, Bottom; }
}
"@ -ErrorAction SilentlyContinue | Out-Null

    $work = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea

    for ($try = 1; $try -le 40; $try++) {
        if ($try -gt 1) { Start-Sleep -Seconds 2 }
        $proc = Get-Process -Name "qemu-system-x86_64" -ErrorAction SilentlyContinue |
            Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } |
            Select-Object -First 1

        if (-not $proc) { continue }

        $hwnd = $proc.MainWindowHandle
        $rect = New-Object EmulatorWinApi+EmuRect
        if (-not [EmulatorWinApi]::GetWindowRect($hwnd, [ref]$rect)) { continue }

        $width = $rect.Right - $rect.Left
        $height = $rect.Bottom - $rect.Top
        if ($width -lt 200 -or $height -lt 200) { continue }

        $x = $work.X + [int](($work.Width - $width) / 2)
        $y = $work.Y + [Math]::Max(40, [int](($work.Height - $height) / 2))
        [EmulatorWinApi]::MoveWindow($hwnd, $x, $y, $width, $height, $true) | Out-Null
        Write-Host "Emulator penceresi ortaya tasindi (${x}, ${y})."
        return $true
    }

    Write-Host "Emulator penceresi otomatik tasinamadi; pencereyi elle surukleyebilirsin."
    return $false
}

if (-not (Test-Path $adb)) {
    Write-Host "HATA: adb bulunamadi: $adb"
    Write-Host "Android Studio > SDK Manager > Android SDK Platform-Tools yukleyin."
    exit 1
}

$freeGb = Get-FreeGb
if ($freeGb -lt $minFreeGb) {
    Write-Host ""
    Write-Host "HATA: C: diskinde yalnizca $freeGb GB bos alan var." -ForegroundColor Red
    Write-Host "Emülatör acilsa bile bir iki dakika icinde kapanabilir (disk dolunca coker)." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Once bos alan ac:" -ForegroundColor Yellow
    Write-Host "  1) .\fix_emulator.ps1 -ClearSnapshots   (~2 GB snapshot silebilir)"
    Write-Host "  2) Geri Donusum Kutusu + Temp + eski dosyalar"
    Write-Host "  3) En az 10 GB bos birak"
    Write-Host ""
    Write-Host "Simdilik web'de calistir: .\run_chrome.ps1"
    exit 1
}

function Get-EmulatorId {
    $lines = & $adb devices | Select-Object -Skip 1
    foreach ($line in $lines) {
        if ($line -match '^(emulator-\d+)\s+device') {
            return $Matches[1]
        }
    }
    return $null
}

Clear-StaleEmulatorLock

$deviceId = Get-EmulatorId
if ($deviceId) {
    Move-EmulatorWindowToCenter | Out-Null
}

if (-not $deviceId) {
    if (-not (Test-Path $emulator)) {
        Write-Host "HATA: emulator bulunamadi. Android Studio'dan bir AVD olusturun."
        exit 1
    }

    $emuArgs = @("-avd", "Pixel6", "-gpu", "swiftshader_indirect", "-scale", "0.75")
    if ($ColdBoot) {
        $emuArgs += @("-no-snapshot-load", "-no-snapshot-save")
        Write-Host "Cold boot: snapshot kapali (daha stabil, biraz yavas acilir)."
    }

    Set-EmulatorWindowCenter -AvdName "Pixel6" -Scale 0.75

    Write-Host "Emulator acik degil. Pixel6 baslatiliyor (yazilim GPU)..."
    Write-Host "Ilk acilis 1-2 dakika surebilir; emulator penceresini kapatmayin."
    Write-Host "C: bos alan: $freeGb GB"

    Start-Process -FilePath $emulator -ArgumentList $emuArgs | Out-Null

    for ($i = 1; $i -le 36; $i++) {
        if ($i -in 1, 2, 3, 4, 6, 8) {
            Move-EmulatorWindowToCenter | Out-Null
        }
        Start-Sleep -Seconds 5
        $deviceId = Get-EmulatorId
        if ($deviceId) {
            Move-EmulatorWindowToCenter | Out-Null
            Write-Host "Emulator hazir: $deviceId"
            break
        }
        Write-Host "Bekleniyor... ($($i * 5)s)"
    }

    if (-not $deviceId) {
        Write-Host ""
        Write-Host "Emulator acilamadi. Denenecekler:"
        Write-Host "  .\fix_emulator.ps1 -ClearSnapshots"
        Write-Host "  .\run_emulator.ps1 -ColdBoot"
        Write-Host "Alternatif: .\run_chrome.ps1"
        exit 1
    }
}

Write-Host "ADB reverse kuruluyor (emulator -> PC:3001)..."
& $adb reverse tcp:3001 tcp:3001

Write-Host "Bagli cihazlar:"
& $adb devices

Write-Host "Flutter baslatiliyor ($deviceId)..."
flutter run -d $deviceId
