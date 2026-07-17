import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class _Candle {
  const _Candle(this.open, this.high, this.low, this.close, this.volume);
  final double open, high, low, close, volume;
  bool get isBullish => close >= open;
}

final _candlesProvider = Provider.family<List<_Candle>, String>((ref, symbol) {
  final rng = Random(symbol.hashCode);
  var price = 50 + rng.nextDouble() * 400;
  final candles = <_Candle>[];
  for (var i = 0; i < 60; i++) {
    final open = price;
    final change = (rng.nextDouble() - 0.48) * price * 0.018;
    final close = open + change;
    final high = max(open, close) + rng.nextDouble() * price * 0.006;
    final low = min(open, close) - rng.nextDouble() * price * 0.006;
    candles.add(_Candle(open, high, low, close, rng.nextDouble() * 1000 + 100));
    price = close;
  }
  return candles;
});

/// Interactive price chart with timeframe switcher — the drill-down view
/// reached from Dashboard, Watchlist, or Scanner tickers.
class ChartScreen extends ConsumerStatefulWidget {
  const ChartScreen({super.key, required this.symbol});
  final String symbol;

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  String _timeframe = '15m';

  @override
  Widget build(BuildContext context) {
    final candles = ref.watch(_candlesProvider(widget.symbol));
    final last = candles.last;
    final first = candles.first;
    final changePct = (last.close - first.open) / first.open * 100;
    final color = changePct >= 0 ? AppColors.bullish : AppColors.bearish;

    final minY = candles.map((c) => c.low).reduce(min);
    final maxY = candles.map((c) => c.high).reduce(max);
    final pad = (maxY - minY) * 0.08;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol.replaceAll('USDT', '/USDT')),
        actions: [
          IconButton(
            tooltip: 'AI Analysis',
            icon: const Icon(Icons.psychology_rounded),
            onPressed: () => context.push('/ai-analysis/${widget.symbol}'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                last.close >= 100 ? last.close.toStringAsFixed(2) : last.close.toStringAsFixed(4),
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: NeonBadge(
                  label: '${changePct >= 0 ? '+' : ''}${changePct.toStringAsFixed(2)}%',
                  color: color,
                  filled: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.timeframes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final tf = AppConstants.timeframes[i];
                final selected = tf == _timeframe;
                return ChoiceChip(
                  label: Text(tf),
                  selected: selected,
                  onSelected: (_) => setState(() => _timeframe = tf),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            child: SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  minY: minY - pad,
                  maxY: maxY + pad,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 4,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 46,
                        interval: (maxY - minY) / 4,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(value >= 100 ? 0 : 2),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(enabled: true),
                  barGroups: [
                    for (var i = 0; i < candles.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            fromY: candles[i].low,
                            toY: candles[i].high,
                            width: 2,
                            color: (candles[i].isBullish ? AppColors.bullish : AppColors.bearish)
                                .withValues(alpha: 0.55),
                          ),
                          BarChartRodData(
                            fromY: min(candles[i].open, candles[i].close),
                            toY: max(candles[i].open, candles[i].close),
                            width: 6,
                            color: candles[i].isBullish ? AppColors.bullish : AppColors.bearish,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/ai-analysis/${widget.symbol}'),
                  icon: const Icon(Icons.psychology_rounded),
                  label: const Text('AI Analysis'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/backtest'),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Backtest'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
