// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleCategoryAdapter extends TypeAdapter<ScheduleCategory> {
  @override
  final int typeId = 11;

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
