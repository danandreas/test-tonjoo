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

  LocalUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        lastName = json['email'],
        email = json['username'],
        gender = json['gender'],
        avatar = json['avatar'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'lastName': lastName,
        'email': email,
        'gender': gender,
        'avatar': avatar,
      };
}
