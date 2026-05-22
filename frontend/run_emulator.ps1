# Emülatör + backend birlikte çalıştır
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"

Write-Host "ADB reverse kuruluyor (emulator -> PC:3001)..."
& $adb reverse tcp:3001 tcp:3001

Write-Host "Emulator kontrol..."
& $adb devices

Write-Host "Flutter baslatiliyor..."
flutter run -d emulator-5554
