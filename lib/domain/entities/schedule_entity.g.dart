// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleEntityAdapter extends TypeAdapter<ScheduleEntity> {
  @override
  final int typeId = 2;

  @override
  ScheduleEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleEntity(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      category: fields[3] as ScheduleCategory,
      dateTime: fields[4] as DateTime,
      notes: fields[5] as String?,
      hasReminder: fields[6] as bool,
      reminderMinutes: fields[7] as int?,
      isCompleted: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      isSynced: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleEntity obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.dateTime)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.hasReminder)
      ..writeByte(7)
      ..write(obj.reminderMinutes)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScheduleCategoryAdapter extends TypeAdapter<ScheduleCategory> {
  @override
  final int typeId = 1;

  @override
  ScheduleCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScheduleCategory.feeding;
      case 1:
        return ScheduleCategory.sleep;
      case 2:
        return ScheduleCategory.health;
      case 3:
        return ScheduleCategory.milestone;
      case 4:
        return ScheduleCategory.other;
      default:
        return ScheduleCategory.feeding;
    }
  }

  @override
  void write(BinaryWriter writer, ScheduleCategory obj) {
    switch (obj) {
      case ScheduleCategory.feeding:
        writer.writeByte(0);
        break;
      case ScheduleCategory.sleep:
        writer.writeByte(1);
        break;
      case ScheduleCategory.health:
        writer.writeByte(2);
        break;
      case ScheduleCategory.milestone:
        writer.writeByte(3);
        break;
      case ScheduleCategory.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
