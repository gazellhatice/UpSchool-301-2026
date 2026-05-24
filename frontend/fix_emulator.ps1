# Emülatör kapanma sorunları için bakim scripti
# Kullanim: .\fix_emulator.ps1
# Snapshot silmek icin: .\fix_emulator.ps1 -ClearSnapshots

param(
    [switch]$ClearSnapshots
)

$sdk = "$env:LOCALAPPDATA\Android\Sdk"
$adb = "$sdk\platform-tools\adb.exe"
$avdHome = "$env:USERPROFILE\.android\avd"
$pixelAvd = "$avdHome\Pixel6.avd"

function Get-FreeGb($path = "C:") {
    $drive = Get-PSDrive ($path.TrimEnd(':')) -ErrorAction SilentlyContinue
    if (-not $drive) { return 0 }
    return [math]::Round($drive.Free / 1GB, 2)
}

Write-Host "=== Emülatör bakım ===" -ForegroundColor Cyan
Write-Host "C: bos alan: $(Get-FreeGb) GB"

if ((Get-FreeGb) -lt 5) {
    Write-Host ""
    Write-Host "UYARI: C: diski neredeyse dolu. Emülatör genelde 1-2 dk icinde kapanir." -ForegroundColor Red
    Write-Host "En az 10 GB bos alan birak (tercihen 15+ GB)." -ForegroundColor Yellow
    Write-Host "Oneriler: Geri Donusum Kutusu, Temp, eski indirmeler, Windows Disk Cleanup." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Eski emulator/qemu surecleri kapatiliyor..."
Get-Process emulator, qemu-system-x86_64 -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

if (Test-Path "$pixelAvd\hardware-qemu.ini.lock") {
    Remove-Item "$pixelAvd\hardware-qemu.ini.lock" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Eski lock dosyasi silindi."
}

$userIni = "$pixelAvd\emulator-user.ini"
if (Test-Path $userIni) {
    $ini = Get-Content $userIni -Raw
    if ($ini -match 'window\.scale\s*=\s*-') {
        @"
window.x = 120
window.y = 80
window.scale = 0.75
resizable.config.id = -1
posture = 0
"@ | Set-Content $userIni -Encoding ASCII
        Write-Host "Bozuk pencere olcegi duzeltildi (window.scale = 0.75)."
    }
}

if ($ClearSnapshots) {
    $snapDir = "$pixelAvd\snapshots"
    if (Test-Path $snapDir) {
        $sizeGb = [math]::Round(((Get-ChildItem $snapDir -Recurse -File | Measure-Object Length -Sum).Sum / 1GB), 2)
        Remove-Item $snapDir -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Path $snapDir -Force | Out-Null
        Write-Host "Snapshot temizlendi (~$sizeGb GB acildi)." -ForegroundColor Green
        Write-Host "C: bos alan simdi: $(Get-FreeGb) GB"
    }
} else {
    Write-Host "Snapshot silmek icin: .\fix_emulator.ps1 -ClearSnapshots"
}

Write-Host ""
Write-Host "Emülatörü cold boot ile ac:" -ForegroundColor Cyan
Write-Host "  .\run_emulator.ps1 -ColdBoot"
Write-Host ""
Write-Host "Alternatif (web):" -ForegroundColor Cyan
Write-Host "  .\run_chrome.ps1"
