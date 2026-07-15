import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/ai_analysis_providers.dart';

/// Deep multi-indicator breakdown for a single symbol: EMA, ADX, ATR,
/// S/R, Supply/Demand, Order Blocks, Liquidity, BOS/CHoCH, FVG, VWAP,
/// Volume, Price Action, Trend, Sentiment, Open Interest, Funding Rate.
class AiAnalysisScreen extends ConsumerWidget {
  const AiAnalysisScreen({super.key, required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(symbolAnalysisProvider(symbol));
    final scoreColor = AppColors.confidence(analysis.overallScore);

    return Scaffold(
      appBar: AppBar(title: Text('${symbol.replaceAll('USDT', '/USDT')} — AI Analysis')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          GlassCard(
            glowColor: scoreColor.withValues(alpha: 0.2),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 44,
                  lineWidth: 9,
                  percent: analysis.overallScore / 100,
                  animation: true,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: AppColors.surfaceElevated,
                  progressColor: scoreColor,
                  center: Text(
                    analysis.overallScore.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Composite Score',
                          style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 4),
                      Text(
                        analysis.sentiment,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: scoreColor),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Derived from ${analysis.indicators.length} weighted technical, structural, and sentiment signals.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Open Interest 24h',
                  value:
                      '${analysis.openInterestChange >= 0 ? '+' : ''}${analysis.openInterestChange.toStringAsFixed(2)}%',
                  color: analysis.openInterestChange >= 0
                      ? AppColors.bullish
                      : AppColors.bearish,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Funding Rate',
                  value: '${(analysis.fundingRate * 100).toStringAsFixed(4)}%',
                  color: analysis.fundingRate >= 0
                      ? AppColors.bullish
                      : AppColors.bearish,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Indicator Breakdown', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          for (final ind in analysis.indicators) ...[
            _IndicatorTile(reading: ind),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _IndicatorTile extends StatelessWidget {
  const _IndicatorTile({required this.reading});
  final IndicatorReading reading;

  Color get _color => switch (reading.bias) {
        IndicatorBias.bullish => AppColors.bullish,
        IndicatorBias.bearish => AppColors.bearish,
        IndicatorBias.neutral => AppColors.warning,
      };

  IconData get _icon => switch (reading.bias) {
        IndicatorBias.bullish => Icons.trending_up_rounded,
        IndicatorBias.bearish => Icons.trending_down_rounded,
        IndicatorBias.neutral => Icons.trending_flat_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 16, color: _color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reading.name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(reading.note, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            reading.value,
            style: TextStyle(color: _color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
