import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

/// Lightweight ticker entity shared across Dashboard, Watchlist, and Scanner
/// while a live exchange integration is wired in (see [EnvConfig.useMockData]).
class TickerSnapshot {
  const TickerSnapshot({
    required this.symbol,
    required this.price,
    required this.changePercent24h,
    required this.volume24h,
    required this.sparkline,
  });

  final String symbol;
  final double price;
  final double changePercent24h;
  final double volume24h;
  final List<double> sparkline;

  bool get isBullish => changePercent24h >= 0;
}

class MarketOverview {
  const MarketOverview({
    required this.fearGreedIndex,
    required this.fearGreedLabel,
    required this.btcDominance,
    required this.totalMarketCapChange,
  });

  final int fearGreedIndex;
  final String fearGreedLabel;
  final double btcDominance;
  final double totalMarketCapChange;
}

/// Deterministic pseudo-random mock generator so the UI has realistic,
/// stable-looking data without requiring network access during development.
/// Swap the implementation inside [MarketDataRepository] (data layer) to
/// point at the real Binance Futures REST/WebSocket feed for production.
List<double> _mockSparkline(Random rng, double base) {
  final points = <double>[];
  var value = base;
  for (var i = 0; i < 24; i++) {
    value += (rng.nextDouble() - 0.5) * base * 0.01;
    points.add(value);
  }
  return points;
}

final marketOverviewProvider = Provider<MarketOverview>((ref) {
  return const MarketOverview(
    fearGreedIndex: 62,
    fearGreedLabel: 'Greed',
    btcDominance: 54.3,
    totalMarketCapChange: 1.8,
  );
});

final homeTickersProvider = Provider<List<TickerSnapshot>>((ref) {
  final rng = Random(7);
  const seed = [
    ('BTCUSDT', 64250.5, 2.14),
    ('ETHUSDT', 3412.8, 1.32),
    ('SOLUSDT', 168.42, -3.21),
    ('XRPUSDT', 0.612, 0.85),
    ('BNBUSDT', 592.1, -1.05),
    ('ADAUSDT', 0.452, 4.62),
    ('DOGEUSDT', 0.1421, -2.44),
  ];
  return [
    for (final s in seed)
      TickerSnapshot(
        symbol: s.$1,
        price: s.$2,
        changePercent24h: s.$3,
        volume24h: rng.nextDouble() * 900000000 + 100000000,
        sparkline: _mockSparkline(rng, s.$2),
      ),
  ];
});

final topGainersProvider = Provider<List<TickerSnapshot>>((ref) {
  final tickers = [...ref.watch(homeTickersProvider)];
  tickers.sort((a, b) => b.changePercent24h.compareTo(a.changePercent24h));
  return tickers.take(3).toList();
});

final topLosersProvider = Provider<List<TickerSnapshot>>((ref) {
  final tickers = [...ref.watch(homeTickersProvider)];
  tickers.sort((a, b) => a.changePercent24h.compareTo(b.changePercent24h));
  return tickers.take(3).toList();
});
