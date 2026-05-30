# Web (Chrome) — emülatör sorununda hızlı test
# Terminal 1: cd backend && npm run dev

$webDir = Join-Path $PSScriptRoot "web"
$sqliteWasm = Join-Path $webDir "sqlite3.wasm"
$driftWorker = Join-Path $webDir "drift_worker.js"

if (-not (Test-Path $sqliteWasm)) {
    Write-Host "sqlite3.wasm indiriliyor..."
    Invoke-WebRequest `
        -Uri "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm" `
        -OutFile $sqliteWasm
}

if (-not (Test-Path $driftWorker)) {
    Write-Host "drift_worker.js indiriliyor..."
    Invoke-WebRequest `
        -Uri "https://github.com/simolus3/drift/releases/download/drift-2.31.0/drift_worker.js" `
        -OutFile $driftWorker
}

Write-Host "Chrome'da baslatiliyor..."
flutter run -d chrome --dart-define=BACKEND_URL=http://127.0.0.1:3001
