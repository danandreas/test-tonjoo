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
import 'package:flutter_andreas/local_db/user_list_model_hive.dart';
import 'package:isar/isar.dart';
import 'package:get/get.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  final TextEditingController _searchController = TextEditingController();
  final String _searchResult = '';

  // void loadInitialDbProvider() async {
  //   final initialDbProvider = Get.put(LocalDb());
  //   await initialDbProvider.initialDb();
  // }

  // makeIsarDB() async {
  //   LocalDb localDB = Get.find();
  //   importjson(localDB.isarUsers);
  // }

  // importjson(Isar isar) async {
  //   await isar.writeTxn(() async {
  //     await isar.listUsers.clear();
  //   });
  //   importContent(isar);
  // }

  // importContent(Isar isar) async {
  //   await isar.writeTxn(() async {
  //     for (var i = 0; i < list_users.length; i++) {
  //       await isar.localUsers.put(LocalUser(
  //           id: list_users[i].id,
  //           username: list_users[i].username,
  //           lastName: list_users[i].lastName,
  //           email: list_users[i].email,
  //           gender: list_users[i].gender,
  //           avatar: list_users[i].avatar));
  //     }
  //   });
  // }

  // ignore: non_constant_identifier_names
  List<UserListModelHive> list_users = [];
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
        List<UserListModelHive> users = [];
        for (var user in jsonData) {
          users.add(UserListModelHive.fromJson(user));
        }
        textLoading = 'Load form server database...';
        return users;
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<UserListModelHive>> readFromHive() async {
    await Hive.initFlutter();
    final box = await Hive.openBox('users');
    List<UserListModelHive> users = [];

    for (var i = 0; i < box.length; i++) {
      final userData = box.getAt(i);
      if (userData != null) {
        users.add(UserListModelHive.fromJson(Map<String, dynamic>.from(userData)));
      }
    }

    return users;

    // final box = await Hive.openBox<UserListModel>('userTable');
    // return box.values.toList();
  }

  Future<void> saveToHive(List<UserListModelHive> userList) async {
    final box = await Hive.openBox<UserListModelHive>('users');
    // await box.clear(); // Clear the box before saving new data.
    

    for (var user in userList) {
      box.add(user); // Add each user object to the box.
    }
    print('simpan');
  }

  Future<void> syncDataWithHive(List<UserListModelHive> data) async {
    await Hive.initFlutter();
    final box = await Hive.openBox('userTable');
    final List<UserListModelHive> hiveData = await readFromHive();

    final List<UserListModelHive> newRecords = data
        .where((fetchedUser) =>
            !hiveData.any((hiveUser) => hiveUser.id == fetchedUser.id))
        .toList();

    final List<UserListModelHive> updatedRecords = data
        .where((fetchedUser) {
      final hiveUser = hiveData.firstWhere(
        (hiveUser) => hiveUser.id == fetchedUser.id,
        // orElse: () => UserListModelHive(), // Provide a default value if not found
      );
      return fetchedUser != hiveUser; // Compare the whole object for changes
    }).toList();

    final List<UserListModelHive> deletedRecords = hiveData
        .where((hiveUser) => !data.any((fetchedUser) => fetchedUser.id == hiveUser.id))
        .toList();

    for (var record in newRecords) {
      await box.add(record.toJson());
    }

    for (var record in updatedRecords) {
      final index = hiveData.indexWhere((user) => user.id == record.id);
      await box.putAt(index, record.toJson());
    }

    for (var record in deletedRecords) {
      final index = hiveData.indexWhere((user) => user.id == record.id);
      if (index != -1) {
        await box.deleteAt(index);
      }
    }
  }

  _loadUsers() async {
    try {
      final userList = await _getUsers(page, limit);
      if (userList != null  && userList.isNotEmpty) {
        print('data from server ==> $userList');
        setState(() {
          list_users.addAll(userList);
          page++;
        });
        
        await saveToHive(list_users);
        // await syncDataWithHive(userList);
      } else {
        textLoading = 'Load from local database...';
        final userBox = Hive.box<UserListModelHive>('users');
        final userListx = userBox.values.toList();
        print('test: $userListx');
        setState(() {
          list_users.addAll(userListx);
        });

        print("fungsi disini");
      }
    } catch (e) {
      print('error: $e');
      return null;
      // error
    }
  }

  void _goSearch() async {

    await Hive.initFlutter();
    final box = await Hive.openBox('userTable');
    final searchResult = box.values.where((person) => person.username == _searchResult).toList();

    if (searchResult.isNotEmpty) {
      for (var person in searchResult) {
        list_users = person;
      }
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
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              Card(
                color: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(
                  color:
                      Colors.transparent,
                  width: 0.25,
                ),
              ),
              elevation: 0,
              margin: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        labelText: '',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                      ),
                      onChanged: (value) {
                        // You can perform some real-time search here if needed
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _goSearch,
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Expanded(
              child: FutureBuilder(
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
                              color:
                                  Colors.grey, // Set the desired border color
                              width: 0.25, // Set the desired border width
                            ),
                          ),
                          elevation: 0,
                          margin: const EdgeInsets.all(5.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(5.0),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user.avatar),
                            ),
                            title: Text('${user.username} ${user.lastName}'),
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.orange.shade900),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      50.0), // Set the desired border radius
                                ),
                              ),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.only(
                                    left: 15,
                                    right: 15), // Set the desired padding
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
              )
            ),
          ],
        ),
      ),
    );
  }
}