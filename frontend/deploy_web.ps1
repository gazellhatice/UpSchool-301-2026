# Web production build + Firebase Hosting deploy
# Kullanım:
#   .\deploy_web.ps1
#   .\deploy_web.ps1 -BackendUrl "https://your-api.onrender.com"

param(
    [string]$BackendUrl = ""
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not $BackendUrl) {
    $BackendUrl = Read-Host "Canlı backend URL (ör. https://xxx.onrender.com)"
}
if (-not $BackendUrl) {
    throw "BACKEND_URL gerekli."
}

$webDir = Join-Path $PSScriptRoot "web"
$wasm = Join-Path $webDir "sqlite3.wasm"
$worker = Join-Path $webDir "drift_worker.js"
if (-not (Test-Path $wasm)) {
    Write-Host "sqlite3.wasm indiriliyor..."
    Invoke-WebRequest -Uri "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm" -OutFile $wasm
}
if (-not (Test-Path $worker)) {
    Write-Host "drift_worker.js indiriliyor..."
    Invoke-WebRequest -Uri "https://github.com/simolus3/drift/releases/download/drift-2.31.0/drift_worker.js" -OutFile $worker
}

Write-Host "Flutter web release build (BACKEND_URL=$BackendUrl)..."
flutter build web --release --no-tree-shake-icons --dart-define=BACKEND_URL=$BackendUrl
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Firebase Hosting deploy..."
firebase deploy --only hosting
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Deploy tamamlandı."
