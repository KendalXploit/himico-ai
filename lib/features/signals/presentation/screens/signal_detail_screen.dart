import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/signals_providers.dart';

/// Full breakdown of a single AI signal: entry/SL/TP ladder, confidence,
/// market structure, liquidity, order flow, and the reasoning chain that
/// produced the call.
class SignalDetailScreen extends ConsumerWidget {
  const SignalDetailScreen({super.key, required this.signalId});
  final String signalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signal = ref.watch(signalByIdProvider(signalId));

    if (signal == null) {
      return const Scaffold(body: Center(child: Text('Signal not found')));
    }

    final tradable = signal.isTradable;
    final isLong = signal.direction == SignalDirection.long;
    final directionColor = !tradable
        ? AppColors.noTrade
        : (isLong ? AppColors.bullish : AppColors.bearish);

    return Scaffold(
      appBar: AppBar(title: Text(signal.symbol.replaceAll('USDT', '/USDT'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          GlassCard(
            glowColor: directionColor.withValues(alpha: 0.2),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tradable
                          ? (isLong
                              ? Icons.arrow_circle_up_rounded
                              : Icons.arrow_circle_down_rounded)
                          : Icons.block_rounded,
                      color: directionColor,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      tradable ? (isLong ? 'LONG SETUP' : 'SHORT SETUP') : 'NO TRADE',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: directionColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${signal.confidence.toStringAsFixed(1)}% confidence',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: signal.confidence / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceElevated,
                    valueColor: AlwaysStoppedAnimation(
                      AppColors.confidence(signal.confidence),
                    ),
                  ),
                ),
                if (!tradable) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Requires ${AppConstants.minSignalConfidence.toStringAsFixed(0)}%+ confidence to publish an entry. HIMICO AI does not force trades.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (tradable) ...[
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  _levelRow(context, 'Entry', signal.entry, AppColors.neonCyan),
                  const Divider(height: 20),
                  _levelRow(context, 'Stop Loss', signal.stopLoss, AppColors.bearish),
                  const Divider(height: 20),
                  _levelRow(context, 'Take Profit 1', signal.tp1, AppColors.bullish),
                  const Divider(height: 20),
                  _levelRow(context, 'Take Profit 2', signal.tp2, AppColors.bullish),
                  const Divider(height: 20),
                  _levelRow(context, 'Take Profit 3', signal.tp3, AppColors.bullish),
                  const Divider(height: 20),
                  _levelRow(
                    context,
                    'Risk : Reward (TP1)',
                    signal.riskRewardTp1,
                    AppColors.textPrimary,
                    isRatio: true,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.account_tree_rounded,
            title: 'Market Structure',
            body: signal.marketStructure,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.water_drop_rounded,
            title: 'Liquidity',
            body: signal.liquidity,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.swap_vert_rounded,
            title: 'Order Flow',
            body: signal.orderFlow,
          ),
          const SizedBox(height: 16),
          Text('Reasoning', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: [
                for (var i = 0; i < signal.reasons.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 16, color: AppColors.neonCyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          signal.reasons[i],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (i != signal.reasons.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                ],
              ],
            ),
          ),
          if (tradable) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to Trade Journal')),
                  );
                },
                icon: const Icon(Icons.bookmark_add_rounded),
                label: const Text('Log to Journal'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _levelRow(
    BuildContext context,
    String label,
    double value,
    Color color, {
    bool isRatio = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          isRatio
              ? '1 : ${value.toStringAsFixed(2)}'
              : (value >= 100 ? value.toStringAsFixed(2) : value.toStringAsFixed(4)),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.neonCyan, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
