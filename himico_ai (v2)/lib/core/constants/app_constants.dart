/// App-wide static constants.
abstract class AppConstants {
  const AppConstants._();

  static const String appName = 'HIMICO AI';
  static const String appTagline = 'Institutional Futures Trading Assistant';

  /// Minimum AI confidence (%) required to emit a tradable signal.
  /// Below this threshold the app must show "NO TRADE".
  static const double minSignalConfidence = 90.0;

  static const List<String> homeSymbols = [
    'BTCUSDT',
    'ETHUSDT',
    'SOLUSDT',
    'XRPUSDT',
    'BNBUSDT',
    'ADAUSDT',
    'DOGEUSDT',
  ];

  static const List<String> timeframes = [
    '1m',
    '5m',
    '15m',
    '1h',
    '4h',
    '1d',
  ];

  static const Duration priceRefreshInterval = Duration(seconds: 3);
  static const Duration scannerRefreshInterval = Duration(minutes: 1);

  static const String hiveWatchlistBox = 'watchlist_box';
  static const String hiveJournalBox = 'journal_box';
  static const String hiveSignalsBox = 'signals_box';
  static const String hiveSettingsBox = 'settings_box';
  static const String hivePortfolioBox = 'portfolio_box';

  static const String secureKeyApiKey = 'exchange_api_key';
  static const String secureKeyApiSecret = 'exchange_api_secret';
}
