// ignore_for_file: file_names

import 'package:isar/isar.dart';

part 'localUser.g.dart';

@Collection()
class LocalUser {
  Id? isarId = Isar.autoIncrement;
  String? id;
  String? username;
  String? lastName;
  String? email;
  String? gender;
  String? avatar;

  LocalUser({
    this.id,
    this.username,
    this.lastName,
    this.email,
    this.gender,
    this.avatar,
  });
}
