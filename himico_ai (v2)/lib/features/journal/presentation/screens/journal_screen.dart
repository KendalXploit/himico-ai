import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/journal_providers.dart';

/// Chronological log of every trade taken (or planned) — entry, exit,
/// reasoning, screenshot, result, and free-form notes.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_rounded, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No journal entries yet', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Log a signal or tap + to add a manual trade',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final e = entries[i];
                final resultColor = switch (e.result) {
                  'WIN' => AppColors.bullish,
                  'LOSS' => AppColors.bearish,
                  'BREAKEVEN' => AppColors.warning,
                  _ => AppColors.noTrade,
                };
                return GlassCard(
                  onTap: () => context.push('/journal/${e.id}'),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 44,
                        decoration: BoxDecoration(
                          color: resultColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e.symbol.replaceAll('USDT', '/USDT')} · ${e.direction}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              e.reason,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      NeonBadge(label: e.result, color: resultColor, filled: true),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final symbolCtrl = TextEditingController(text: 'BTCUSDT');
    final entryCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    String direction = 'LONG';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Journal Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: symbolCtrl,
                decoration: const InputDecoration(labelText: 'Symbol'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: direction,
                items: const [
                  DropdownMenuItem(value: 'LONG', child: Text('LONG')),
                  DropdownMenuItem(value: 'SHORT', child: Text('SHORT')),
                ],
                onChanged: (v) => setState(() => direction = v ?? 'LONG'),
                decoration: const InputDecoration(labelText: 'Direction'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: entryCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Entry Price'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final entry = double.tryParse(entryCtrl.text) ?? 0;
                await ref.read(journalControllerProvider).addEntry(
                      symbol: symbolCtrl.text.trim().toUpperCase(),
                      direction: direction,
                      entry: entry,
                      reason: reasonCtrl.text.trim().isEmpty
                          ? 'Manual entry'
                          : reasonCtrl.text.trim(),
                    );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
