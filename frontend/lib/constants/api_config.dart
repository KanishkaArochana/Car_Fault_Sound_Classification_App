import 'package:flutter_dotenv/flutter_dotenv.dart';

// Backend inference server configuration loaded from .env.
class ApiConfig {
  ApiConfig._();

  // Emulator or physical device flag
  static bool get useAndroidEmulator =>
      (dotenv.maybeGet('USE_ANDROID_EMULATOR') ?? 'false').toLowerCase() == 'true';

  // Computer local IP for physical device testing
  static String get _computerLocalIp =>
      dotenv.maybeGet('COMPUTER_LOCAL_IP') ?? '192.168.8.143';

  // Emulator host IP alias
  static String get _emulatorHostAlias =>
      dotenv.maybeGet('EMULATOR_HOST_ALIAS') ?? '127.0.0.1';

  // Backend server port
  static String get _apiPort =>
      dotenv.maybeGet('API_PORT') ?? '8000';

  static String get baseUrl => useAndroidEmulator
      ? 'http://$_emulatorHostAlias:$_apiPort'
      : 'http://$_computerLocalIp:$_apiPort';

  static String get predictEndpoint => '$baseUrl/predict';
  static String get healthEndpoint => '$baseUrl/health';

  // Network request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
}
