import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/shell/presentation/screens/app_shell.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/scanner/presentation/screens/scanner_screen.dart';
import '../../features/signals/presentation/screens/signals_screen.dart';
import '../../features/signals/presentation/screens/signal_detail_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/watchlist/presentation/screens/watchlist_screen.dart';
import '../../features/ai_analysis/presentation/screens/ai_analysis_screen.dart';
import '../../features/chart/presentation/screens/chart_screen.dart';
import '../../features/backtest/presentation/screens/backtest_screen.dart';
import '../../features/journal/presentation/screens/journal_screen.dart';
import '../../features/journal/presentation/screens/journal_entry_screen.dart';

/// Root navigator + per-tab navigators, so each bottom-nav branch keeps
/// its own back stack (StatefulShellRoute) — matches TradingView/Binance-
/// style navigation where switching tabs preserves scroll/state.
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    debugLogDiagnostics: false,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/scanner',
              builder: (context, state) => const ScannerScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/signals',
              builder: (context, state) => const SignalsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => SignalDetailScreen(
                    signalId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/portfolio',
              builder: (context, state) => const PortfolioScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
      // Full-screen routes pushed on top of the shell.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/watchlist',
        builder: (context, state) => const WatchlistScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/ai-analysis/:symbol',
        builder: (context, state) => AiAnalysisScreen(
          symbol: state.pathParameters['symbol']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/chart/:symbol',
        builder: (context, state) => ChartScreen(
          symbol: state.pathParameters['symbol']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/backtest',
        builder: (context, state) => const BacktestScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/journal',
        builder: (context, state) => const JournalScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => JournalEntryScreen(
              entryId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
});
