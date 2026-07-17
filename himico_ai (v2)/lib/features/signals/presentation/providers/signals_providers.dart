import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';

enum SignalDirection { long, short, noTrade }

class TradeSignal {
  const TradeSignal({
    required this.id,
    required this.symbol,
    required this.direction,
    required this.confidence,
    required this.entry,
    required this.stopLoss,
    required this.tp1,
    required this.tp2,
    required this.tp3,
    required this.marketStructure,
    required this.liquidity,
    required this.orderFlow,
    required this.reasons,
    required this.timeframe,
    required this.createdAt,
  });

  final String id;
  final String symbol;
  final SignalDirection direction;
  final double confidence;
  final double entry;
  final double stopLoss;
  final double tp1;
  final double tp2;
  final double tp3;
  final String marketStructure;
  final String liquidity;
  final String orderFlow;
  final List<String> reasons;
  final String timeframe;
  final DateTime createdAt;

  bool get isTradable =>
      direction != SignalDirection.noTrade &&
      confidence >= AppConstants.minSignalConfidence;

  double get riskRewardTp1 => direction == SignalDirection.long
      ? (tp1 - entry).abs() / (entry - stopLoss).abs()
      : (entry - tp1).abs() / (stopLoss - entry).abs();
}

final _rawSignalsProvider = Provider<List<TradeSignal>>((ref) {
  final rng = Random(11);
  final symbols = AppConstants.homeSymbols +
      ['AVAXUSDT', 'LINKUSDT', 'ARBUSDT', 'SUIUSDT', 'INJUSDT'];

  final reasonPool = [
    'Break of structure confirmed on 1H with strong displacement',
    'Price swept liquidity below prior swing low',
    'Bullish order block retested with volume confirmation',
    'Fair value gap filled precisely at 61.8% retracement',
    'VWAP reclaim with rising volume delta',
    'ADX above 25 confirming trending regime',
    'EMA 21/50 bullish cross on 4H timeframe',
    'Open interest rising alongside price — trend-confirming',
    'Funding rate near neutral, no crowding risk',
    'Rejection wick at major daily resistance',
    'CHoCH detected, momentum shifting bearish',
    'Volume spike 3.2x average on breakout candle',
  ];

  return [
    for (var i = 0; i < symbols.length; i++)
      _buildSignal(rng, symbols[i], reasonPool, i),
  ];
});

TradeSignal _buildSignal(
  Random rng,
  String symbol,
  List<String> reasonPool,
  int seedOffset,
) {
  final confidence = 55 + rng.nextDouble() * 44; // 55–99
  final directionRoll = rng.nextDouble();
  final direction = confidence < AppConstants.minSignalConfidence
      ? SignalDirection.noTrade
      : (directionRoll > 0.5 ? SignalDirection.long : SignalDirection.short);

  final price = 1 + rng.nextDouble() * 500;
  final atr = price * (0.005 + rng.nextDouble() * 0.02);
  final isLong = direction == SignalDirection.long;

  final entry = price;
  final stopLoss = isLong ? price - atr * 1.5 : price + atr * 1.5;
  final tp1 = isLong ? price + atr * 1.5 : price - atr * 1.5;
  final tp2 = isLong ? price + atr * 2.6 : price - atr * 2.6;
  final tp3 = isLong ? price + atr * 4.2 : price - atr * 4.2;

  final shuffled = [...reasonPool]..shuffle(rng);
  final reasons = shuffled.take(3 + rng.nextInt(3)).toList();

  final structures = [
    'Bullish BOS on 4H, HH/HL sequence intact',
    'Bearish CHoCH on 1H, distribution phase',
    'Ranging between key S/R, no clear structure',
  ];
  final liquidityNotes = [
    'Buy-side liquidity resting above equal highs',
    'Sell-side liquidity swept, reversal likely',
    'Liquidity pool untouched — magnet for price',
  ];
  final orderFlowNotes = [
    'Aggressive market buys absorbing offers',
    'Passive selling into strength, exhaustion signs',
    'Balanced order flow, awaiting catalyst',
  ];

  return TradeSignal(
    id: '$symbol-${seedOffset}',
    symbol: symbol,
    direction: direction,
    confidence: confidence,
    entry: entry,
    stopLoss: stopLoss,
    tp1: tp1,
    tp2: tp2,
    tp3: tp3,
    marketStructure: structures[rng.nextInt(structures.length)],
    liquidity: liquidityNotes[rng.nextInt(liquidityNotes.length)],
    orderFlow: orderFlowNotes[rng.nextInt(orderFlowNotes.length)],
    reasons: reasons,
    timeframe: AppConstants.timeframes[rng.nextInt(AppConstants.timeframes.length)],
    createdAt: DateTime.now().subtract(Duration(minutes: rng.nextInt(240))),
  );
}

final signalsProvider = Provider<List<TradeSignal>>((ref) {
  final signals = [...ref.watch(_rawSignalsProvider)];
  signals.sort((a, b) => b.confidence.compareTo(a.confidence));
  return signals;
});

final tradableSignalsProvider = Provider<List<TradeSignal>>((ref) {
  return ref.watch(signalsProvider).where((s) => s.isTradable).toList();
});

final signalByIdProvider = Provider.family<TradeSignal?, String>((ref, id) {
  for (final s in ref.watch(signalsProvider)) {
    if (s.id == id) return s;
  }
  return null;
});
