import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class _Position {
  const _Position(this.symbol, this.direction, this.size, this.entry, this.mark, this.pnlPercent);
  final String symbol;
  final String direction;
  final double size;
  final double entry;
  final double mark;
  final double pnlPercent;
}

final _positionsProvider = Provider<List<_Position>>((ref) {
  final rng = Random(5);
  final symbols = ['BTCUSDT', 'ETHUSDT', 'SOLUSDT'];
  return [
    for (final s in symbols)
      _Position(
        s,
        rng.nextBool() ? 'LONG' : 'SHORT',
        500 + rng.nextDouble() * 2000,
        10 + rng.nextDouble() * 400,
        10 + rng.nextDouble() * 400,
        (rng.nextDouble() - 0.4) * 10,
      ),
  ];
});

/// Account overview: equity, open positions, and allocation breakdown.
class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = ref.watch(_positionsProvider);
    final totalPnl = positions.fold<double>(0, (s, p) => s + p.pnlPercent);
    const equity = 24380.55;

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          GlassCard(
            glowColor: AppColors.neonBlue.withValues(alpha: 0.16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Equity', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 6),
                Text('\$${equity.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 6),
                NeonBadge(
                  label: '${totalPnl >= 0 ? '+' : ''}${totalPnl.toStringAsFixed(2)}% unrealized',
                  color: totalPnl >= 0 ? AppColors.bullish : AppColors.bearish,
                  filled: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Allocation', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          GlassCard(
            child: SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                  sections: [
                    for (var i = 0; i < positions.length; i++)
                      PieChartSectionData(
                        value: positions[i].size,
                        color: [
                          AppColors.neonBlue,
                          AppColors.neonCyan,
                          AppColors.neonPurple,
                        ][i % 3],
                        title: positions[i].symbol.replaceAll('USDT', ''),
                        radius: 46,
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Open Positions', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          for (final p in positions) ...[
            _PositionCard(position: p),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({required this.position});
  final _Position position;

  @override
  Widget build(BuildContext context) {
    final color = position.pnlPercent >= 0 ? AppColors.bullish : AppColors.bearish;
    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      position.symbol.replaceAll('USDT', '/USDT'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(width: 8),
                    NeonBadge(
                      label: position.direction,
                      color: position.direction == 'LONG'
                          ? AppColors.bullish
                          : AppColors.bearish,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Size \$${position.size.toStringAsFixed(0)} · Entry ${position.entry.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${position.pnlPercent >= 0 ? '+' : ''}${position.pnlPercent.toStringAsFixed(2)}%',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
