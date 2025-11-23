// Compile-time configuration values passed via `--dart-define`.
// Example: flutter build apk --dart-define=API_URL=https://api.prod.example/upload
const String kApiUrlCompileTime = String.fromEnvironment('API_URL', defaultValue: '');
