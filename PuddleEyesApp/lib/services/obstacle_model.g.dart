// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'obstacle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObstacleAdapter extends TypeAdapter<Obstacle> {
  @override
  final int typeId = 0;

  @override
  Obstacle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Obstacle(
      lat: fields[0] as double,
      lon: fields[1] as double,
      depth: fields[2] as double,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Obstacle obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lon)
      ..writeByte(2)
      ..write(obj.depth)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObstacleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
