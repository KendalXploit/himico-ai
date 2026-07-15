import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/journal_entry_model.dart';

/// Opens (or creates) the Hive box used to persist trade-journal entries.
/// Called once during app bootstrap in `main.dart`.
Future<Box<JournalEntryModel>> openJournalBox() async {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(JournalEntryModelAdapter());
  }
  return Hive.openBox<JournalEntryModel>(AppConstants.hiveJournalBox);
}

final journalBoxProvider = Provider<Box<JournalEntryModel>>((ref) {
  throw UnimplementedError(
    'journalBoxProvider must be overridden in main.dart after openJournalBox()',
  );
});

final journalEntriesProvider = Provider<List<JournalEntryModel>>((ref) {
  final box = ref.watch(journalBoxProvider);
  final entries = box.values.toList();
  entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return entries;
});

final journalEntryByIdProvider =
    Provider.family<JournalEntryModel?, String>((ref, id) {
  final entries = ref.watch(journalEntriesProvider);
  for (final e in entries) {
    if (e.id == id) return e;
  }
  return null;
});

class JournalController {
  JournalController(this._box);
  final Box<JournalEntryModel> _box;

  Future<void> addEntry({
    required String symbol,
    required String direction,
    required double entry,
    required String reason,
    String? screenshotPath,
    String result = 'OPEN',
    String notes = '',
  }) async {
    final id = const Uuid().v4();
    final model = JournalEntryModel(
      id: id,
      symbol: symbol,
      direction: direction,
      entry: entry,
      reason: reason,
      screenshotPath: screenshotPath,
      result: result,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await _box.put(id, model);
  }

  Future<void> updateEntry(JournalEntryModel model) async {
    await model.save();
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
  }
}

final journalControllerProvider = Provider<JournalController>((ref) {
  return JournalController(ref.watch(journalBoxProvider));
});
