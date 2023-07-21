import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_andreas/config/local_db.dart';
import 'package:flutter_andreas/local_db/listUser.dart';
import 'package:flutter_andreas/pages/user_list_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/url.dart';
import 'package:flutter_andreas/local_db/localUser.dart';
import 'package:isar/isar.dart';
import 'package:get/get.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {

  void loadInitialDbProvider() async {
    final initialDbProvider = Get.put(LocalDb());
    await initialDbProvider.initialDb();
  }

  makeIsarDB() async {
    LocalDb localDB = Get.find();
    importjson(localDB.isarUsers);
  }
  importjson(Isar isar) async {
    await isar.writeTxn(() async {
      await isar.listUsers.clear();
    });
    importContent( isar);
  }

  importContent(Isar isar) async {
    await isar.writeTxn(() async {
      for (var i = 0; i < list_users.length; i++) {
        await isar.localUsers.put(LocalUser(
          id: list_users[i].id,
          username: list_users[i].username,
          lastName: list_users[i].lastName,
          email: list_users[i].email,
          gender: list_users[i].gender,
          avatar: list_users[i].avatar
      ));
      }
    });
  }
  // ignore: non_constant_identifier_names
  List<UserListModel> list_users = [];
  int page = 1;
  int limit = 2;
  late String textLoading = 'Loading...';

  Future<dynamic> _getUsers(page, limit) async {
    try {
      final url = '${Api.baseUrl}users?page=$page&limit=$limit';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200) {

        List<UserListModel> users = [];
        for (var user in jsonData) {
          users.add(UserListModel.fromJson(user));
        }

        // dimasukkan ke isar
        // var data = await jsonData.map((userJson) => UserListModel.fromJson(userJson)).toList();
        // makeIsarDB();
        // users = data;
         // dimasukkan ke Hive
        await syncDataWithHive(users);
        textLoading = 'Load form server database...';
        // users = data;
        return users;
      } else {
        return readFromHive();
      }
    } catch (e) {
      return readFromHive();
    }
  }

  Future<List<UserListModel>> readFromHive() async {
    await Hive.initFlutter();
    final box = await Hive.openBox('userBox');
    List<UserListModel> users = [];

    for (var i = 0; i < box.length; i++) {
      final userData = box.getAt(i);
      if (userData != null) {
        users.add(UserListModel.fromJson(Map<String, dynamic>.from(userData)));
      }
    }

    return users;
  }
  
  Future<void> syncDataWithHive(List<UserListModel> data) async {
    await Hive.initFlutter();
    final box = await Hive.openBox('userBox');
    final List<UserListModel> hiveData = await readFromHive();

    // Find new records to add
    final List<UserListModel> newRecords = data
        .where((fetchedUser) => !hiveData.any((hiveUser) => hiveUser.id == fetchedUser.id))
        .toList();

    // Find updated records to update
    final List<UserListModel> updatedRecords = data
        .where((fetchedUser) =>
            hiveData.any((hiveUser) =>
                hiveUser.id == fetchedUser.id && (hiveUser.username != fetchedUser.username)))
        .toList();

    // Find deleted records to delete
    final List<UserListModel> deletedRecords = hiveData
        .where((hiveUser) => !data.any((fetchedUser) => fetchedUser.id == hiveUser.id))
        .toList();

    // Perform necessary operations to sync data
    for (var record in newRecords) {
      await box.add(record.toJson());
    }

    for (var record in updatedRecords) {
      final index = hiveData.indexWhere((user) => user.id == record.id);
      await box.putAt(index, record.toJson());
    }

    for (var record in deletedRecords) {
      final index = hiveData.indexWhere((user) => user.id == record.id);
      await box.deleteAt(index);
    }
  }

  // Future<List<LocalUser>> getPersonsFromIsar() async {
  //   var dir = await getApplicationDocumentsDirectory();
  //   var isarx = await Isar.open(
  //     [LocalUserSchema],
  //     directory: dir.path,
  //   );
  //   final getUserLocal = await isarx.localUsers.where().findAll();
  //   await isarx.close();
  //   textLoading = 'Load form local database...';
  //   return getUserLocal;
  // }

  void _loadUsers() async {
    try {
      final userList = await _getUsers(page, limit);
      setState(() {
        list_users.addAll(userList);
        page++;
      });
    } catch (e) {
      // getPersonsFromIsar();
      final userLocal = await readFromHive();
      setState(() {
        list_users.addAll(userLocal);
      });
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
        child: 
        FutureBuilder(
          initialData: list_users,
          future: _getUsers(page, limit),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            inspect(snapshot.data);
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

