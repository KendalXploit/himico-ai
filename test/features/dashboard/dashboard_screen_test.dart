import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:himico_ai/core/theme/app_theme.dart';
import 'package:himico_ai/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  group('DashboardScreen', () {
    testWidgets('renders app name, tagline, and home symbols', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const DashboardScreen(),
          ),
        ),
      );

      // Let the initial frame + any microtasks settle.
      await tester.pump();

      expect(find.text('HIMICO AI'), findsOneWidget);
      expect(find.text('Institutional Futures Trading Assistant'), findsOneWidget);
      expect(find.text('Watchlist'), findsOneWidget);
      expect(find.text('Top Gainers'), findsOneWidget);
      expect(find.text('Top Losers'), findsOneWidget);
    });
  });
}
