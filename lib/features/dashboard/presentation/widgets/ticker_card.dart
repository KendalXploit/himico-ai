import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/market_data_providers.dart';

/// Compact ticker card: symbol, live price, 24h change, and a mini
/// sparkline — the primary building block of the Dashboard's watch row.
class TickerCard extends StatelessWidget {
  const TickerCard({super.key, required this.ticker, this.onTap});

  final TickerSnapshot ticker;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = ticker.isBullish ? AppColors.bullish : AppColors.bearish;
    final base = ticker.symbol.replaceAll('USDT', '');

    return SizedBox(
      width: 152,
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        glowColor: color.withValues(alpha: 0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  base,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(
                  ticker.isBullish
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 16,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              ticker.price >= 100
                  ? ticker.price.toStringAsFixed(1)
                  : ticker.price.toStringAsFixed(4),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 2),
            Text(
              '${ticker.isBullish ? '+' : ''}${ticker.changePercent24h.toStringAsFixed(2)}%',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < ticker.sparkline.length; i++)
                          FlSpot(i.toDouble(), ticker.sparkline[i]),
                      ],
                      isCurved: true,
                      barWidth: 1.6,
                      color: color,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color.withValues(alpha: 0.25),
                            color.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
