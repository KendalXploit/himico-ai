import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/scanner_providers.dart';

/// Scans all USDT-M futures pairs for structural setups: breakouts,
/// retests, order blocks, FVGs, volume spikes, supply/demand zones.
class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(scanResultsProvider);
    final timeframe = ref.watch(scannerTimeframeProvider);
    final filter = ref.watch(scannerFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Scanner'),
        actions: [
          PopupMenuButton<String>(
            initialValue: timeframe,
            onSelected: (tf) =>
                ref.read(scannerTimeframeProvider.notifier).state = tf,
            itemBuilder: (context) => [
              for (final tf in AppConstants.timeframes)
                PopupMenuItem(value: tf, child: Text(tf)),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: NeonBadge(label: timeframe, icon: Icons.schedule_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: ScanSignalType.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final tag = ScanSignalType.values[i];
                final selected = filter.contains(tag);
                return FilterChip(
                  label: Text(tag.label),
                  avatar: Icon(tag.icon, size: 14),
                  selected: selected,
                  onSelected: (_) {
                    final next = {...filter};
                    selected ? next.remove(tag) : next.add(tag);
                    ref.read(scannerFilterProvider.notifier).state = next;
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No pairs match these filters'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _ScanResultCard(result: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScanResultCard extends StatelessWidget {
  const _ScanResultCard({required this.result});
  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final changeColor =
        result.changePercent >= 0 ? AppColors.bullish : AppColors.bearish;

    return GlassCard(
      onTap: () => context.push('/ai-analysis/${result.symbol}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.symbol.replaceAll('USDT', '/USDT'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${result.changePercent >= 0 ? '+' : ''}${result.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                    color: changeColor, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              NeonBadge(
                label: result.structure.label,
                color: result.structure.color,
                filled: true,
              ),
              const SizedBox(width: 8),
              Icon(Icons.water_drop_rounded,
                  size: 13, color: AppColors.neonCyan),
              const SizedBox(width: 3),
              Text(
                'Liquidity ${result.liquidityScore.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 10),
              Icon(Icons.bar_chart_rounded, size: 13, color: AppColors.warning),
              const SizedBox(width: 3),
              Text(
                'Vol ${result.volumeRatio.toStringAsFixed(1)}x',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in result.tags)
                NeonBadge(label: tag.label, icon: tag.icon),
            ],
          ),
        ],
      ),
    );
  }
}
