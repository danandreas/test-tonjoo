import 'package:hive/hive.dart';

part 'user_list_model_hive.g.dart';

@HiveType(typeId: 0)
class UserListModelHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String lastName;

  @HiveField(3)
  String email;

  @HiveField(4)
  String gender;

  @HiveField(5)
  String avatar;

  UserListModelHive({
    required this.id,
    required this.username,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.avatar,
  });

  factory UserListModelHive.fromJson(Map<String, dynamic> json) {
    return UserListModelHive(
      id: json['id'],
      username: json['username'],
      lastName: json['last_name'],
      email: json['email'],
      gender: json['gender'],
      avatar: json['avatar']      
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'last_name': lastName,
    'email': email,
    'gender': gender,
    'avatar': avatar,
  };
}