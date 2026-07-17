import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/journal_providers.dart';

/// View / edit a single journal entry: attach a screenshot, record the
/// exit price, mark the result, and free-write post-trade notes.
class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({super.key, required this.entryId});
  final String entryId;

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  late final TextEditingController _notesCtrl;
  late final TextEditingController _exitCtrl;

  @override
  void initState() {
    super.initState();
    final entry = ref.read(journalEntryByIdProvider(widget.entryId));
    _notesCtrl = TextEditingController(text: entry?.notes ?? '');
    _exitCtrl = TextEditingController(text: entry?.exit?.toString() ?? '');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = ref.watch(journalEntryByIdProvider(widget.entryId));
    if (entry == null) {
      return const Scaffold(body: Center(child: Text('Entry not found')));
    }

    final resultColor = switch (entry.result) {
      'WIN' => AppColors.bullish,
      'LOSS' => AppColors.bearish,
      'BREAKEVEN' => AppColors.warning,
      _ => AppColors.noTrade,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.symbol.replaceAll('USDT', '/USDT')),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              await ref.read(journalControllerProvider).deleteEntry(entry.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          GlassCard(
            child: Row(
              children: [
                NeonBadge(label: entry.direction, color: AppColors.neonBlue),
                const SizedBox(width: 8),
                NeonBadge(label: entry.result, color: resultColor, filled: true),
                const Spacer(),
                DropdownButton<String>(
                  value: entry.result,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'OPEN', child: Text('OPEN')),
                    DropdownMenuItem(value: 'WIN', child: Text('WIN')),
                    DropdownMenuItem(value: 'LOSS', child: Text('LOSS')),
                    DropdownMenuItem(value: 'BREAKEVEN', child: Text('BREAKEVEN')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    entry.result = v;
                    ref.read(journalControllerProvider).updateEntry(entry);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                _row(context, 'Entry Price', entry.entry.toStringAsFixed(4)),
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _exitCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Exit Price'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded),
                      color: AppColors.neonCyan,
                      onPressed: () {
                        entry.exit = double.tryParse(_exitCtrl.text);
                        ref.read(journalControllerProvider).updateEntry(entry);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('Reason', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          GlassCard(child: Text(entry.reason, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(height: 16),
          Text('Screenshot', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          GlassCard(
            child: entry.screenshotPath != null && File(entry.screenshotPath!).existsSync()
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(entry.screenshotPath!), fit: BoxFit.cover),
                  )
                : Column(
                    children: [
                      Icon(Icons.image_outlined, size: 40, color: AppColors.textMuted),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final img = await picker.pickImage(source: ImageSource.gallery);
                          if (img != null) {
                            entry.screenshotPath = img.path;
                            await ref.read(journalControllerProvider).updateEntry(entry);
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate_rounded),
                        label: const Text('Attach Screenshot'),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Text('Notes', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 5,
            decoration: const InputDecoration(hintText: 'Post-trade reflection...'),
            onChanged: (v) {
              entry.notes = v;
              ref.read(journalControllerProvider).updateEntry(entry);
            },
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
