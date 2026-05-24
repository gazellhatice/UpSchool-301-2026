# Web (Chrome) — emülatör sorununda hızlı test
# Terminal 1: cd backend && npm run dev

Write-Host "Chrome'da baslatiliyor..."
flutter run -d chrome --dart-define=BACKEND_URL=http://localhost:3001
