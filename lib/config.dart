/// Live API on VPS. Override for local dev:
/// `flutter run --dart-define=API_URL=http://10.0.2.2:4000/api` (Android emulator)
/// `flutter run --dart-define=API_URL=http://127.0.0.1:4000/api` (iOS simulator)
const _defaultApi = 'http://72.61.241.114:8088/api';

String apiBaseUrl() {
  const fromEnv = String.fromEnvironment('API_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  return _defaultApi;
}
