import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';

Future<Box> openSettingsBox() => Hive.openBox(AppConstants.hiveSettingsBox);

final settingsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError(
    'settingsBoxProvider must be overridden in main.dart after openSettingsBox()',
  );
});

class AppSettings {
  const AppSettings({
    required this.notificationsEnabled,
    required this.language,
    required this.exchange,
    required this.riskPerTradePercent,
    required this.leverage,
  });

  final bool notificationsEnabled;
  final String language;
  final String exchange;
  final double riskPerTradePercent;
  final int leverage;

  AppSettings copyWith({
    bool? notificationsEnabled,
    String? language,
    String? exchange,
    double? riskPerTradePercent,
    int? leverage,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      exchange: exchange ?? this.exchange,
      riskPerTradePercent: riskPerTradePercent ?? this.riskPerTradePercent,
      leverage: leverage ?? this.leverage,
    );
  }
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._box)
      : super(AppSettings(
          notificationsEnabled: _box.get('notificationsEnabled', defaultValue: true) as bool,
          language: _box.get('language', defaultValue: 'English') as String,
          exchange: _box.get('exchange', defaultValue: 'Binance Futures') as String,
          riskPerTradePercent:
              (_box.get('riskPerTradePercent', defaultValue: 1.0) as num).toDouble(),
          leverage: _box.get('leverage', defaultValue: 10) as int,
        ));

  final Box _box;

  void setNotifications(bool value) {
    _box.put('notificationsEnabled', value);
    state = state.copyWith(notificationsEnabled: value);
  }

  void setLanguage(String value) {
    _box.put('language', value);
    state = state.copyWith(language: value);
  }

  void setExchange(String value) {
    _box.put('exchange', value);
    state = state.copyWith(exchange: value);
  }

  void setRisk(double value) {
    _box.put('riskPerTradePercent', value);
    state = state.copyWith(riskPerTradePercent: value);
  }

  void setLeverage(int value) {
    _box.put('leverage', value);
    state = state.copyWith(leverage: value);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController(ref.watch(settingsBoxProvider));
});
