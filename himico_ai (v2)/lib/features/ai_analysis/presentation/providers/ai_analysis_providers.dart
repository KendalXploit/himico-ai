import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum IndicatorBias { bullish, bearish, neutral }

class IndicatorReading {
  const IndicatorReading({
    required this.name,
    required this.value,
    required this.bias,
    required this.note,
  });

  final String name;
  final String value;
  final IndicatorBias bias;
  final String note;
}

class SymbolAnalysis {
  const SymbolAnalysis({
    required this.symbol,
    required this.overallScore,
    required this.sentiment,
    required this.indicators,
    required this.openInterestChange,
    required this.fundingRate,
  });

  final String symbol;
  final double overallScore; // 0-100 bullish score
  final String sentiment;
  final List<IndicatorReading> indicators;
  final double openInterestChange;
  final double fundingRate;
}

final symbolAnalysisProvider =
    Provider.family<SymbolAnalysis, String>((ref, symbol) {
  final rng = Random(symbol.hashCode);

  IndicatorBias biasOf(double v) =>
      v > 0.6 ? IndicatorBias.bullish : (v < 0.4 ? IndicatorBias.bearish : IndicatorBias.neutral);

  final defs = <(String, String Function(Random), String)>[
    ('EMA 21/50/200', (r) => r.nextBool() ? 'Bullish stack' : 'Bearish stack', 'Trend-following moving average alignment'),
    ('ADX (14)', (r) => (15 + r.nextInt(45)).toString(), 'Trend strength — above 25 signals a trending regime'),
    ('ATR (14)', (r) => (0.4 + r.nextDouble() * 3).toStringAsFixed(2) + '%', 'Volatility used to size stop-loss distance'),
    ('Support / Resistance', (r) => r.nextBool() ? 'Near resistance' : 'Near support', 'Key horizontal levels from swing highs/lows'),
    ('Supply / Demand', (r) => r.nextBool() ? 'Fresh demand zone' : 'Tested supply zone', 'Institutional order zones'),
    ('Order Block', (r) => r.nextBool() ? 'Bullish OB intact' : 'Bearish OB intact', 'Last opposing candle before displacement'),
    ('Liquidity', (r) => r.nextBool() ? 'Buy-side resting above' : 'Sell-side resting below', 'Stop clusters likely to be swept'),
    ('BOS', (r) => r.nextBool() ? 'Confirmed' : 'Not confirmed', 'Break of Structure — trend continuation signal'),
    ('CHoCH', (r) => r.nextBool() ? 'Detected' : 'None', 'Change of Character — early reversal signal'),
    ('Fair Value Gap', (r) => r.nextBool() ? 'Unfilled FVG above' : 'Unfilled FVG below', 'Imbalance likely to be revisited'),
    ('VWAP', (r) => r.nextBool() ? 'Price above VWAP' : 'Price below VWAP', 'Volume-weighted average price'),
    ('Volume', (r) => '${(0.5 + r.nextDouble() * 3).toStringAsFixed(1)}x avg', 'Relative to 20-period average volume'),
    ('Price Action', (r) => r.nextBool() ? 'Bullish engulfing' : 'Bearish pinbar', 'Latest candlestick pattern'),
    ('Trend (HTF)', (r) => r.nextBool() ? 'Uptrend' : 'Downtrend', 'Higher timeframe directional bias'),
    ('Sentiment', (r) => r.nextBool() ? 'Greed' : 'Fear', 'Aggregated social + derivatives sentiment'),
  ];

  final indicators = <IndicatorReading>[];
  var bullishCount = 0;
  for (final d in defs) {
    final biasRoll = rng.nextDouble();
    final bias = biasOf(biasRoll);
    if (bias == IndicatorBias.bullish) bullishCount++;
    indicators.add(IndicatorReading(
      name: d.$1,
      value: d.$2(rng),
      bias: bias,
      note: d.$3,
    ));
  }

  final score = (bullishCount / defs.length) * 100;

  return SymbolAnalysis(
    symbol: symbol,
    overallScore: score,
    sentiment: score >= 60 ? 'Bullish Bias' : (score <= 40 ? 'Bearish Bias' : 'Neutral / Mixed'),
    indicators: indicators,
    openInterestChange: (rng.nextDouble() - 0.4) * 8,
    fundingRate: (rng.nextDouble() - 0.5) * 0.06,
  );
});
