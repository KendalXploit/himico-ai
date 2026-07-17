import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BacktestTrade {
  const BacktestTrade({
    required this.symbol,
    required this.direction,
    required this.entry,
    required this.exit,
    required this.pnlPercent,
    required this.date,
  });

  final String symbol;
  final String direction;
  final double entry;
  final double exit;
  final double pnlPercent;
  final DateTime date;

  bool get isWin => pnlPercent > 0;
}

class BacktestResult {
  const BacktestResult({
    required this.trades,
    required this.equityCurve,
    required this.monthlyReturns,
  });

  final List<BacktestTrade> trades;
  final List<double> equityCurve;
  final Map<String, double> monthlyReturns;

  int get wins => trades.where((t) => t.isWin).length;
  int get losses => trades.length - wins;
  double get winRate => trades.isEmpty ? 0 : wins / trades.length * 100;

  double get profitFactor {
    final grossProfit = trades.where((t) => t.isWin).fold<double>(0, (s, t) => s + t.pnlPercent);
    final grossLoss = trades.where((t) => !t.isWin).fold<double>(0, (s, t) => s + t.pnlPercent.abs());
    if (grossLoss == 0) return grossProfit > 0 ? double.infinity : 0;
    return grossProfit / grossLoss;
  }

  double get maxDrawdown {
    var peak = equityCurve.first;
    var maxDd = 0.0;
    for (final v in equityCurve) {
      if (v > peak) peak = v;
      final dd = (peak - v) / peak * 100;
      if (dd > maxDd) maxDd = dd;
    }
    return maxDd;
  }
}

final backtestResultProvider = Provider<BacktestResult>((ref) {
  final rng = Random(99);
  final symbols = ['BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'XRPUSDT', 'BNBUSDT'];
  final trades = <BacktestTrade>[];
  var equity = 10000.0;
  final curve = <double>[equity];
  final now = DateTime.now();

  for (var i = 0; i < 84; i++) {
    final win = rng.nextDouble() < 0.58;
    final pnl = win ? (0.6 + rng.nextDouble() * 3.4) : -(0.4 + rng.nextDouble() * 2.2);
    final entry = 10 + rng.nextDouble() * 400;
    final exit = entry * (1 + pnl / 100);
    equity *= (1 + pnl / 100 * 0.15); // position-sized impact on equity
    curve.add(equity);
    trades.add(BacktestTrade(
      symbol: symbols[rng.nextInt(symbols.length)],
      direction: rng.nextBool() ? 'LONG' : 'SHORT',
      entry: entry,
      exit: exit,
      pnlPercent: pnl,
      date: now.subtract(Duration(days: 84 - i)),
    ));
  }

  final monthly = <String, double>{};
  for (final t in trades) {
    final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
    monthly[key] = (monthly[key] ?? 0) + t.pnlPercent;
  }

  return BacktestResult(trades: trades, equityCurve: curve, monthlyReturns: monthly);
});
