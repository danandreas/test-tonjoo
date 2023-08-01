class UserListModel {
  final String id;
  String? username;
  String? lastName;
  String? email;
  String? gender;
  String? avatar;

  UserListModel({
    required this.id,
    this.username,
    this.lastName,
    this.email,
    this.gender,
    this.avatar,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    return UserListModel(
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
    'avatar': avatar
  };

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'last_name': lastName,
      'email': email,
      'gender': gender,
      'avatar': avatar
    };
  }
}
