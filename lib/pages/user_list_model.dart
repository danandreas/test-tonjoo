class UserListModel {
  String? id;
  final String username;
  final String lastName;
  final String email;
  final String gender;
  final String avatar;

  UserListModel({
    this.id,
    required this.username,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.avatar,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    return UserListModel(
      id: json['id'],
      username: json['username'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      avatar: json['avatar'] ?? ''      
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
