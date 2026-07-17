import 'package:flutter_test/flutter_test.dart';
import 'package:himico_ai/features/signals/presentation/providers/signals_providers.dart';

void main() {
  group('TradeSignal.isTradable', () {
    test('is false when confidence is below the 90% threshold', () {
      final signal = TradeSignal(
        id: 't1',
        symbol: 'BTCUSDT',
        direction: SignalDirection.long,
        confidence: 89.9,
        entry: 100,
        stopLoss: 98,
        tp1: 102,
        tp2: 104,
        tp3: 106,
        marketStructure: 'test',
        liquidity: 'test',
        orderFlow: 'test',
        reasons: const ['test'],
        timeframe: '1h',
        createdAt: DateTime.now(),
      );

      expect(signal.isTradable, isFalse);
    });

    test('is true when confidence is >= 90% and direction is set', () {
      final signal = TradeSignal(
        id: 't2',
        symbol: 'BTCUSDT',
        direction: SignalDirection.short,
        confidence: 93.4,
        entry: 100,
        stopLoss: 102,
        tp1: 98,
        tp2: 96,
        tp3: 94,
        marketStructure: 'test',
        liquidity: 'test',
        orderFlow: 'test',
        reasons: const ['test'],
        timeframe: '4h',
        createdAt: DateTime.now(),
      );

      expect(signal.isTradable, isTrue);
    });

    test('is always false for SignalDirection.noTrade regardless of confidence', () {
      final signal = TradeSignal(
        id: 't3',
        symbol: 'ETHUSDT',
        direction: SignalDirection.noTrade,
        confidence: 99.0,
        entry: 100,
        stopLoss: 98,
        tp1: 102,
        tp2: 104,
        tp3: 106,
        marketStructure: 'test',
        liquidity: 'test',
        orderFlow: 'test',
        reasons: const ['test'],
        timeframe: '15m',
        createdAt: DateTime.now(),
      );

      expect(signal.isTradable, isFalse);
    });
  });
}
