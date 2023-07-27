// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_model_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserListModelHiveAdapter extends TypeAdapter<UserListModelHive> {
  @override
  final int typeId = 0;

  @override
  UserListModelHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserListModelHive(
      id: fields[0] as String,
      username: fields[1] as String,
      lastName: fields[2] as String,
      email: fields[3] as String,
      gender: fields[4] as String,
      avatar: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserListModelHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.avatar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserListModelHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
