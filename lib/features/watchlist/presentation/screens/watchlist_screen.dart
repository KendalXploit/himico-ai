import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../dashboard/presentation/providers/market_data_providers.dart';

/// User-managed symbol list. Backed by [homeTickersProvider] mock data for
/// now — swap for a Hive-persisted [WatchlistRepository] to survive restarts
/// and sync custom symbols.
final watchlistSymbolsProvider = StateProvider<Set<String>>(
  (ref) => {'BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'XRPUSDT', 'BNBUSDT', 'ADAUSDT', 'DOGEUSDT'},
);

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTickers = ref.watch(homeTickersProvider);
    final watched = ref.watch(watchlistSymbolsProvider);
    final list = allTickers.where((t) => watched.contains(t.symbol)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddSymbolSheet(context, ref, allTickers),
          ),
        ],
      ),
      body: list.isEmpty
          ? const Center(child: Text('Your watchlist is empty'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final t = list[i];
                final color = t.isBullish ? AppColors.bullish : AppColors.bearish;
                return GlassCard(
                  onTap: () => context.push('/chart/${t.symbol}'),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Text(
                          t.symbol.replaceAll('USDT', '').substring(0, 1),
                          style: TextStyle(color: color, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.symbol.replaceAll('USDT', '/USDT'),
                                style: Theme.of(context).textTheme.titleSmall),
                            Text(
                              t.price >= 100
                                  ? t.price.toStringAsFixed(2)
                                  : t.price.toStringAsFixed(4),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      NeonBadge(
                        label:
                            '${t.isBullish ? '+' : ''}${t.changePercent24h.toStringAsFixed(2)}%',
                        color: color,
                        filled: true,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          final next = {...watched}..remove(t.symbol);
                          ref.read(watchlistSymbolsProvider.notifier).state = next;
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showAddSymbolSheet(
    BuildContext context,
    WidgetRef ref,
    List<TickerSnapshot> all,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final watched = ref.watch(watchlistSymbolsProvider);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Symbol', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              for (final t in all)
                CheckboxListTile(
                  value: watched.contains(t.symbol),
                  title: Text(t.symbol.replaceAll('USDT', '/USDT')),
                  onChanged: (checked) {
                    final next = {...watched};
                    checked == true ? next.add(t.symbol) : next.remove(t.symbol);
                    ref.read(watchlistSymbolsProvider.notifier).state = next;
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
