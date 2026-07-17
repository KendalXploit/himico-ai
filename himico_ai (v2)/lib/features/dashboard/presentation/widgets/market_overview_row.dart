import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/market_data_providers.dart';

/// Row of at-a-glance market health stats: Fear & Greed Index and
/// BTC Dominance, styled as glowing gauges.
class MarketOverviewRow extends StatelessWidget {
  const MarketOverviewRow({super.key, required this.overview});

  final MarketOverview overview;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            child: Column(
              children: [
                Text('FEAR & GREED', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 10),
                CircularPercentIndicator(
                  radius: 34,
                  lineWidth: 7,
                  percent: overview.fearGreedIndex / 100,
                  animation: true,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: AppColors.surfaceElevated,
                  progressColor: AppColors.confidence(overview.fearGreedIndex.toDouble()),
                  center: Text(
                    '${overview.fearGreedIndex}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  overview.fearGreedLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.confidence(overview.fearGreedIndex.toDouble()),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            child: Column(
              children: [
                Text('BTC DOMINANCE', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 10),
                CircularPercentIndicator(
                  radius: 34,
                  lineWidth: 7,
                  percent: overview.btcDominance / 100,
                  animation: true,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: AppColors.surfaceElevated,
                  progressColor: AppColors.neonBlue,
                  center: Text(
                    '${overview.btcDominance.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${overview.totalMarketCapChange >= 0 ? '+' : ''}${overview.totalMarketCapChange.toStringAsFixed(2)}% mcap',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: overview.totalMarketCapChange >= 0
                            ? AppColors.bullish
                            : AppColors.bearish,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
