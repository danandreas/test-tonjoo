import 'package:flutter/material.dart';
import 'package:flutter_andreas/config/local_db.dart';
import 'package:flutter_andreas/local_db/listUser.dart';
import 'package:flutter_andreas/pages/user_list_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/url.dart';
import 'package:flutter_andreas/local_db/localUser.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {

  UserListModel userListModel = UserListModel();

  makeIsarDB(LocalUser response) async {
    LocalDb localDB = Get.find();
    importjson(localDB.isarUsers, response);
  }
  importjson(Isar isar, LocalUser response) async {
    // await isar.writeTxn(() async {
    //   await isar.listUsers.clear();
    // });
    importContent(response, isar);
  }

  importContent(LocalUser response, Isar isar) async {
    final List<LocalUser> users = response as List<LocalUser>;
    await isar.writeTxn(() async {
      // await isar.localUsers.put(LocalUser(
      //     id: response.id,
      //     username: response.username,
      //     lastName: response.lastName,
      //     email: response.email,
      //     gender: response.gender,
      //     avatar: response.avatar
      // ));
      for (var user in users) {
        await isar.localUsers.put(user);
      }
    });
  }
  // ignore: non_constant_identifier_names
  List<User> list_users = [];
  int page = 1;
  int limit = 2;
  late String textLoading = 'Loading...';

  Future<dynamic> _getUsers(page, limit) async {
    try {
      final url = '${Api.baseUrl}users?page=$page&limit=$limit';
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        List<User> users = [];
        for (var u in jsonData) {
          User user = User(
              u["id"] ?? "",
              u["username"] ?? "",
              u["gender"] ?? "",
              u["last_name"] ?? "",
              u["email"] ?? "",
              u["avatar"] ?? "");
          users.add(user);
        }

        // var data = jsonData.map((userJson) => LocalUser.fromJson(userJson)).toList();
        // makeIsarDB(data);
        // await makeIsarDB(jsonData.map((userJson) => UserListModel.fromJson(userJson)).toList());

        print(jsonData.map((userJson) => LocalUser.fromJson(userJson)).toList());
        final List<LocalUser> usersx = jsonData.map((userJson) => LocalUser.fromJson(userJson)).toList();
        
        makeIsarDB(usersx as LocalUser);

        textLoading = 'Load form server database...';
        return users;
      } else {
        return [];
      }
    } catch (e) {
      // return getPersonsFromIsar();
    }
  }

  Future<List<LocalUser>> getPersonsFromIsar() async {
    var dir = await getApplicationDocumentsDirectory();
    var isarx = await Isar.open(
      [LocalUserSchema],
      directory: dir.path,
    );
    final getUserLocal = await isarx.localUsers.where().findAll();
    await isarx.close();
    textLoading = 'Load form local database...';
    return getUserLocal;
  }

  void _loadUsers() async {
    try {
      final userList = await _getUsers(page, limit);
      setState(() {
          list_users.addAll(userList);
          page++;
        });
      print(list_users.length);
    } catch (e) {
      // getPersonsFromIsar();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List User"),
        backgroundColor: Colors.orange.shade900,
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: FutureBuilder(
          future: _getUsers(page, limit),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(child: Text(textLoading));
            } else {
              return ListView.builder(
                itemCount: list_users.length + 1,
                itemBuilder: (context, index) {
                  if (index < list_users.length) {
                    final user = list_users[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: Colors.grey, // Set the desired border color
                          width: 0.25, // Set the desired border width
                        ),
                      ),
                      elevation: 0,
                      margin: const EdgeInsets.all(5.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(5.0),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.avatar ?? ''),
                        ),
                        title: Text(user.username),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.gender,
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              user.email,
                            ),
                          ],
                        ),
                        // trailing: const Icon(Icons.clear),
                      ),
                    );
                  } else {
                    return Container(
                      width: 200.0,
                      height: 60.0,
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.orange.shade900),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0), // Set the desired border radius
                            ),
                          ),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.only(left: 15, right: 15), // Set the desired padding
                          ),
                        ),
                        onPressed: _loadUsers,
                        child: const Text('Load More'),
                      ),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class User {
  final String id;
  final String username;
  final String gender;
  final String lastName;
  final String email;
  // ignore: prefer_void_to_null, avoid_init_to_null
  String? avatar = null;

  User(this.id, this.username, this.gender, this.lastName, this.email,
      this.avatar);
}
