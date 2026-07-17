// GENERATED CODE - EQUIVALENT OF build_runner OUTPUT
// This adapter is hand-written to match what `flutter pub run build_runner
// build` would emit for JournalEntryModel, so the project compiles out of
// the box. If you add/remove @HiveField members, regenerate with:
//   flutter pub run build_runner build --delete-conflicting-outputs

part of 'journal_entry_model.dart';

class JournalEntryModelAdapter extends TypeAdapter<JournalEntryModel> {
  @override
  final int typeId = 0;

  @override
  JournalEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalEntryModel(
      id: fields[0] as String,
      symbol: fields[1] as String,
      direction: fields[2] as String,
      entry: fields[3] as double,
      exit: fields[4] as double?,
      reason: fields[5] as String,
      screenshotPath: fields[6] as String?,
      result: fields[7] as String,
      notes: fields[8] as String,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntryModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.direction)
      ..writeByte(3)
      ..write(obj.entry)
      ..writeByte(4)
      ..write(obj.exit)
      ..writeByte(5)
      ..write(obj.reason)
      ..writeByte(6)
      ..write(obj.screenshotPath)
      ..writeByte(7)
      ..write(obj.result)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
