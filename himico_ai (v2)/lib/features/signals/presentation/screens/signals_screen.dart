import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/signals_providers.dart';

/// AI Signal feed. Only setups with confidence >= [AppConstants.minSignalConfidence]
/// are tradable — everything else renders as "NO TRADE" so the trader never
/// mistakes a low-conviction read for an actionable signal.
class SignalsScreen extends ConsumerWidget {
  const SignalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signals = ref.watch(signalsProvider);
    final tradableCount = signals.where((s) => s.isTradable).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Signals'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: NeonBadge(
                label: '$tradableCount ACTIVE',
                color: AppColors.bullish,
                filled: true,
                icon: Icons.bolt_rounded,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: signals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _SignalCard(signal: signals[i]),
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({required this.signal});
  final TradeSignal signal;

  @override
  Widget build(BuildContext context) {
    final tradable = signal.isTradable;
    final isLong = signal.direction == SignalDirection.long;
    final directionColor = !tradable
        ? AppColors.noTrade
        : (isLong ? AppColors.bullish : AppColors.bearish);

    return GlassCard(
      onTap: () => context.push('/signals/${signal.id}'),
      glowColor: tradable ? directionColor.withValues(alpha: 0.18) : null,
      borderColor: tradable ? directionColor.withValues(alpha: 0.5) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                tradable
                    ? (isLong
                        ? Icons.arrow_circle_up_rounded
                        : Icons.arrow_circle_down_rounded)
                    : Icons.block_rounded,
                color: directionColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  signal.symbol.replaceAll('USDT', '/USDT'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              NeonBadge(
                label: signal.timeframe,
                color: AppColors.neonBlue,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ConfidenceMeter(confidence: signal.confidence),
              ),
              const SizedBox(width: 12),
              NeonBadge(
                label: tradable
                    ? (isLong ? 'LONG' : 'SHORT')
                    : 'NO TRADE',
                color: directionColor,
                filled: true,
              ),
            ],
          ),
          if (tradable) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _PriceStat(label: 'Entry', value: signal.entry),
                _PriceStat(label: 'SL', value: signal.stopLoss, color: AppColors.bearish),
                _PriceStat(label: 'TP1', value: signal.tp1, color: AppColors.bullish),
              ],
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              'Confidence below ${AppConstants.minSignalConfidence.toStringAsFixed(0)}% threshold — no actionable edge.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfidenceMeter extends StatelessWidget {
  const _ConfidenceMeter({required this.confidence});
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.confidence(confidence);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('AI CONFIDENCE', style: Theme.of(context).textTheme.labelSmall),
            Text(
              '${confidence.toStringAsFixed(1)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: confidence / 100,
            minHeight: 6,
            backgroundColor: AppColors.surfaceElevated,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _PriceStat extends StatelessWidget {
  const _PriceStat({required this.label, required this.value, this.color});
  final String label;
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value >= 100 ? value.toStringAsFixed(1) : value.toStringAsFixed(4),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
