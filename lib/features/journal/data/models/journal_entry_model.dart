import 'package:hive/hive.dart';

part 'journal_entry_model.g.dart';

/// Persisted trade-journal entry. Every published AI signal — and any
/// manually logged trade — is stored here via Hive so the trader keeps a
/// permanent, offline-first record independent of the live signal feed.
@HiveType(typeId: 0)
class JournalEntryModel extends HiveObject {
  JournalEntryModel({
    required this.id,
    required this.symbol,
    required this.direction,
    required this.entry,
    this.exit,
    required this.reason,
    this.screenshotPath,
    required this.result,
    this.notes = '',
    required this.createdAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String symbol;

  @HiveField(2)
  final String direction; // LONG / SHORT

  @HiveField(3)
  final double entry;

  @HiveField(4)
  double? exit;

  @HiveField(5)
  final String reason;

  @HiveField(6)
  String? screenshotPath;

  @HiveField(7)
  String result; // WIN / LOSS / OPEN / BREAKEVEN

  @HiveField(8)
  String notes;

  @HiveField(9)
  final DateTime createdAt;
}
