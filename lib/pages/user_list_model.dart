class UserListModel {
  String? id;
  String? username;
  String? lastName;
  String? email;
  String? gender;
  String? avatar;

  UserListModel({
    this.id,
    this.username,
    this.lastName,
    this.email,
    this.gender,
    this.avatar,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    return UserListModel(
      id: json['id'] as String?,
      username: json['username'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      gender: json['gender'] as String?,
      avatar: json['avatar'] as String?,
      
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'lastName': lastName,
    'email': email,
    'gender': gender,
    'avatar': avatar,
  };
}
