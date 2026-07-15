import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Wraps environment configuration loaded from `.env`.
/// Falls back to sane defaults so the app runs even without a `.env` file
/// (public market-data endpoints only — no keys required for read-only data).
abstract class EnvConfig {
  const EnvConfig._();

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env is optional in development; public endpoints still work.
    }
  }

  static String get binanceFuturesBaseUrl =>
      dotenv.env['BINANCE_FUTURES_BASE_URL'] ??
      'https://fapi.binance.com';

  static String get binanceFuturesWsUrl =>
      dotenv.env['BINANCE_FUTURES_WS_URL'] ??
      'wss://fstream.binance.com/stream';

  static String get aiApiBaseUrl =>
      dotenv.env['AI_API_BASE_URL'] ?? '';

  static String get aiApiKey => dotenv.env['AI_API_KEY'] ?? '';

  static bool get useMockData =>
      (dotenv.env['USE_MOCK_DATA'] ?? 'true').toLowerCase() == 'true';
}
