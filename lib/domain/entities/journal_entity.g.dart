// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JournalEntityAdapter extends TypeAdapter<JournalEntity> {
  @override
  final int typeId = 4;

  @override
  JournalEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalEntity(
      id: fields[0] as String,
      userId: fields[1] as String,
      date: fields[2] as DateTime,
      mood: fields[3] as MoodType,
      content: fields[4] as String,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      isSynced: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodTypeAdapter extends TypeAdapter<MoodType> {
  @override
  final int typeId = 3;

  @override
  MoodType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MoodType.veryHappy;
      case 1:
        return MoodType.happy;
      case 2:
        return MoodType.neutral;
      case 3:
        return MoodType.sad;
      case 4:
        return MoodType.verySad;
      default:
        return MoodType.veryHappy;
    }
  }

  @override
  void write(BinaryWriter writer, MoodType obj) {
    switch (obj) {
      case MoodType.veryHappy:
        writer.writeByte(0);
        break;
      case MoodType.happy:
        writer.writeByte(1);
        break;
      case MoodType.neutral:
        writer.writeByte(2);
        break;
      case MoodType.sad:
        writer.writeByte(3);
        break;
      case MoodType.verySad:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
