import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

enum ScanSignalType {
  breakout,
  retest,
  orderBlock,
  fairValueGap,
  volumeSpike,
  supply,
  demand,
  support,
  resistance,
}

extension ScanSignalTypeX on ScanSignalType {
  String get label => switch (this) {
        ScanSignalType.breakout => 'Breakout',
        ScanSignalType.retest => 'Retest',
        ScanSignalType.orderBlock => 'Order Block',
        ScanSignalType.fairValueGap => 'FVG',
        ScanSignalType.volumeSpike => 'Volume Spike',
        ScanSignalType.supply => 'Supply Zone',
        ScanSignalType.demand => 'Demand Zone',
        ScanSignalType.support => 'Support',
        ScanSignalType.resistance => 'Resistance',
      };

  IconData get icon => switch (this) {
        ScanSignalType.breakout => Icons.rocket_launch_rounded,
        ScanSignalType.retest => Icons.replay_rounded,
        ScanSignalType.orderBlock => Icons.view_agenda_rounded,
        ScanSignalType.fairValueGap => Icons.space_bar_rounded,
        ScanSignalType.volumeSpike => Icons.bar_chart_rounded,
        ScanSignalType.supply => Icons.arrow_downward_rounded,
        ScanSignalType.demand => Icons.arrow_upward_rounded,
        ScanSignalType.support => Icons.horizontal_rule_rounded,
        ScanSignalType.resistance => Icons.horizontal_rule_rounded,
      };
}

enum MarketStructure { bullish, bearish, ranging }

class ScanResult {
  const ScanResult({
    required this.symbol,
    required this.timeframe,
    required this.price,
    required this.changePercent,
    required this.structure,
    required this.tags,
    required this.liquidityScore,
    required this.volumeRatio,
  });

  final String symbol;
  final String timeframe;
  final double price;
  final double changePercent;
  final MarketStructure structure;
  final List<ScanSignalType> tags;
  final double liquidityScore; // 0-100
  final double volumeRatio; // multiple of avg volume
}

final scannerTimeframeProvider = StateProvider<String>((ref) => '15m');

final scannerFilterProvider =
    StateProvider<Set<ScanSignalType>>((ref) => <ScanSignalType>{});

final _rawScanResultsProvider = Provider<List<ScanResult>>((ref) {
  final rng = Random(42);
  final pairs = [
    'BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'XRPUSDT', 'BNBUSDT', 'ADAUSDT',
    'DOGEUSDT', 'AVAXUSDT', 'LINKUSDT', 'DOTUSDT', 'TONUSDT', 'NEARUSDT',
    'ARBUSDT', 'OPUSDT', 'SUIUSDT', 'APTUSDT', 'INJUSDT', 'TIAUSDT',
  ];
  final structures = MarketStructure.values;
  final allTags = ScanSignalType.values;

  return [
    for (final p in pairs)
      ScanResult(
        symbol: p,
        timeframe: '15m',
        price: rng.nextDouble() * 500 + 0.1,
        changePercent: (rng.nextDouble() - 0.5) * 12,
        structure: structures[rng.nextInt(structures.length)],
        tags: (allTags..shuffle(rng)).take(1 + rng.nextInt(3)).toList(),
        liquidityScore: rng.nextDouble() * 100,
        volumeRatio: 0.6 + rng.nextDouble() * 3.2,
      ),
  ];
});

final scanResultsProvider = Provider<List<ScanResult>>((ref) {
  final results = ref.watch(_rawScanResultsProvider);
  final filter = ref.watch(scannerFilterProvider);
  if (filter.isEmpty) return results;
  return results.where((r) => r.tags.any(filter.contains)).toList();
});

extension MarketStructureX on MarketStructure {
  String get label => switch (this) {
        MarketStructure.bullish => 'Bullish BOS',
        MarketStructure.bearish => 'Bearish CHoCH',
        MarketStructure.ranging => 'Ranging',
      };

  Color get color => switch (this) {
        MarketStructure.bullish => AppColors.bullish,
        MarketStructure.bearish => AppColors.bearish,
        MarketStructure.ranging => AppColors.warning,
      };
}
