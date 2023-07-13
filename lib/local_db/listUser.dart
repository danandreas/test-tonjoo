// ignore_for_file: file_names

import 'package:isar/isar.dart';

part 'listUser.g.dart';

@Collection()
class ListUser {
  Id? isarId = Isar.autoIncrement;
  String? id;
  String? username;
  String? lastName;
  String? email;
  String? gender;
  String? avatar;

  ListUser({
    this.id,
    this.username,
    this.lastName,
    this.email,
    this.gender,
    this.avatar,
  });
}
