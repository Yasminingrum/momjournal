// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotoEntityAdapter extends TypeAdapter<PhotoEntity> {
  @override
  final int typeId = 5;

  @override
  PhotoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhotoEntity(
      id: fields[0] as String,
      userId: fields[1] as String,
      dateTaken: fields[6] as DateTime,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      localPath: fields[2] as String?,
      cloudUrl: fields[3] as String?,
      caption: fields[4] as String?,
      category: fields[13] as String?,
      isMilestone: fields[5] as bool,
      isFavorite: fields[14] as bool,
      isSynced: fields[9] as bool,
      isUploaded: fields[10] as bool,
      isDeleted: fields[11] as bool,
      deletedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PhotoEntity obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.localPath)
      ..writeByte(3)
      ..write(obj.cloudUrl)
      ..writeByte(4)
      ..write(obj.caption)
      ..writeByte(5)
      ..write(obj.isMilestone)
      ..writeByte(6)
      ..write(obj.dateTaken)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.isUploaded)
      ..writeByte(11)
      ..write(obj.isDeleted)
      ..writeByte(12)
      ..write(obj.deletedAt)
      ..writeByte(13)
      ..write(obj.category)
      ..writeByte(14)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
