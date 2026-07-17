import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/market_data_providers.dart';
import '../widgets/market_overview_row.dart';
import '../widgets/ticker_card.dart';

/// HIMICO AI home screen.
///
/// Shows the primary watch symbols, market health gauges, and top
/// gainers/losers — the trader's first read of the market on app open.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickers = ref.watch(homeTickersProvider);
    final overview = ref.watch(marketOverviewProvider);
    final gainers = ref.watch(topGainersProvider);
    final losers = ref.watch(topLosersProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(context: context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverToBoxAdapter(
                child: MarketOverviewRow(overview: overview),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Watchlist',
                actionLabel: 'View all',
                onAction: () => context.push('/watchlist'),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 168,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tickers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final t = tickers[index];
                    return TickerCard(
                      ticker: t,
                      onTap: () => context.push('/chart/${t.symbol}'),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Top Gainers',
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.bullish,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _MoversList(tickers: gainers),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Top Losers',
                icon: Icons.trending_down_rounded,
                iconColor: AppColors.bearish,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _MoversList(tickers: losers),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonBlue.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppConstants.appName, style: textTheme.displaySmall),
                Text(
                  AppConstants.appTagline,
                  style: textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor ?? AppColors.neonCyan),
                const SizedBox(width: 6),
              ],
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class _MoversList extends StatelessWidget {
  const _MoversList({required this.tickers});
  final List<TickerSnapshot> tickers;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < tickers.length; i++) ...[
            _MoverTile(ticker: tickers[i]),
            if (i != tickers.length - 1)
              const Divider(height: 1, indent: 14, endIndent: 14),
          ],
        ],
      ),
    );
  }
}

class _MoverTile extends StatelessWidget {
  const _MoverTile({required this.ticker});
  final TickerSnapshot ticker;

  @override
  Widget build(BuildContext context) {
    final color = ticker.isBullish ? AppColors.bullish : AppColors.bearish;
    return ListTile(
      onTap: () => context.push('/chart/${ticker.symbol}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Text(
          ticker.symbol.replaceAll('USDT', '').substring(0, 1),
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(
        ticker.symbol.replaceAll('USDT', '/USDT'),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
      ),
      subtitle: Text(
        ticker.price >= 100
            ? ticker.price.toStringAsFixed(1)
            : ticker.price.toStringAsFixed(4),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: NeonBadge(
        label:
            '${ticker.isBullish ? '+' : ''}${ticker.changePercent24h.toStringAsFixed(2)}%',
        color: color,
        filled: true,
      ),
    );
  }
}
