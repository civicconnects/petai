// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetAdapter extends TypeAdapter<Pet> {
  @override
  final int typeId = 0;

  @override
  Pet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pet(
      id: fields[0] as String,
      name: fields[1] as String,
      breed: fields[2] as String,
      age: fields[3] as int,
      color: fields[7] as String,
      idNumber: fields[4] as String,
      weight: fields[5] as double,
      sex: fields[6] as String,
      chronicConditions: (fields[8] as List).cast<String>(),
      imagePath: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.breed)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.idNumber)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.sex)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.chronicConditions)
      ..writeByte(9)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
