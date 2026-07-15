import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/backtest_providers.dart';

/// Strategy backtesting dashboard: performance stats, equity curve,
/// monthly returns heat row, trade log, and CSV export.
class BacktestScreen extends ConsumerWidget {
  const BacktestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(backtestResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backtest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: 'Export CSV',
            onPressed: () => _exportCsv(context, result),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Win Rate',
                  value: '${result.winRate.toStringAsFixed(1)}%',
                  color: AppColors.bullish,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Profit Factor',
                  value: result.profitFactor.isFinite
                      ? result.profitFactor.toStringAsFixed(2)
                      : '∞',
                  color: AppColors.neonCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Max Drawdown',
                  value: '-${result.maxDrawdown.toStringAsFixed(1)}%',
                  color: AppColors.bearish,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Total Trades',
                  value: '${result.trades.length}',
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Equity Curve', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) =>
                        FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < result.equityCurve.length; i++)
                          FlSpot(i.toDouble(), result.equityCurve[i]),
                      ],
                      isCurved: true,
                      barWidth: 2,
                      color: AppColors.neonCyan,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.neonCyan.withValues(alpha: 0.25),
                            AppColors.neonCyan.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Monthly Performance', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          GlassCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in result.monthlyReturns.entries)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: (entry.value >= 0 ? AppColors.bullish : AppColors.bearish)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (entry.value >= 0 ? AppColors.bullish : AppColors.bearish)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(entry.key, style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          '${entry.value >= 0 ? '+' : ''}${entry.value.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: entry.value >= 0 ? AppColors.bullish : AppColors.bearish,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Trade Log', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < result.trades.length.clamp(0, 15); i++) ...[
                  _TradeRow(trade: result.trades[result.trades.length - 1 - i]),
                  if (i != 14) const Divider(height: 1, indent: 14, endIndent: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, BacktestResult result) async {
    final rows = <List<dynamic>>[
      ['Date', 'Symbol', 'Direction', 'Entry', 'Exit', 'PnL %'],
      for (final t in result.trades)
        [
          t.date.toIso8601String(),
          t.symbol,
          t.direction,
          t.entry.toStringAsFixed(4),
          t.exit.toStringAsFixed(4),
          t.pnlPercent.toStringAsFixed(2),
        ],
    ];
    final csv = const ListToCsvConverter().convert(rows);

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/himico_backtest.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)], text: 'HIMICO AI Backtest Export');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed on this platform')),
        );
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});
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
                .headlineMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TradeRow extends StatelessWidget {
  const _TradeRow({required this.trade});
  final BacktestTrade trade;

  @override
  Widget build(BuildContext context) {
    final color = trade.isWin ? AppColors.bullish : AppColors.bearish;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: NeonBadge(label: trade.direction, color: color),
      title: Text(
        trade.symbol.replaceAll('USDT', '/USDT'),
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        '${trade.date.year}-${trade.date.month.toString().padLeft(2, '0')}-${trade.date.day.toString().padLeft(2, '0')}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        '${trade.pnlPercent >= 0 ? '+' : ''}${trade.pnlPercent.toStringAsFixed(2)}%',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
