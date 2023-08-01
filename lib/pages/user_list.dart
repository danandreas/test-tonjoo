import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_andreas/pages/user_list_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/url.dart';
import '../local_db/user_table.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  final TextEditingController _searchController = TextEditingController();
  final tbUser = UserTable();
  final String _searchResult = '';

  // ignore: non_constant_identifier_names
  List<UserListModel> list_users = [];
  int page = 1;
  int pageSearch = 1;
  int pageOffline = 0;
  int limit = 2;
  late String textLoading = 'Loading...';

  Future<dynamic> _getUsers(page, limit) async {
    try {
      final url = '${Api.baseUrl}users?page=$page&limit=$limit';
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        final dbHelper = UserTable();
        List<UserListModel> users = [];
        for (var user in jsonData) {
          UserListModel userModel = UserListModel.fromJson(user);
          await dbHelper.storeOrUpdate(userModel);
            users.add(userModel);
        }
        textLoading = 'Load form server database...';
        return users;
      } else {
        print('Error else');
        throw Exception('Failed to load users.');
      }

    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  _loadUsers() async {
    try {
      final userList = await _getUsers(page, limit);
      if (userList != null && userList.isNotEmpty) {
        print('data from server ==> $userList');
        setState(() {
          list_users.addAll(userList);
          page++;
        });
        print(page);
      } else {
        
        textLoading = 'Load from local database...';
        final dbHelperz = UserTable();
        // await dbHelperz.clearUsersTable();
        List<UserListModel> users = await dbHelperz.getUsersPaginate(page, limit, '');
        setState(() {
          // list_users = users;
          list_users.addAll(users);
          page++;
        });
      }
    } catch (e) {
      print('error: $e');
      return null;
      // error
    }
  }

  void _goSearch() async {
    pageSearch = 1;
    String searchText = _searchController.text;
    print('cari: $searchText');
    final dbHelperx = UserTable();
    List<UserListModel> users = await dbHelperx.getUsersPaginate(pageSearch, limit, searchText);
    setState(() {
      list_users.clear();
      Set<String> uniqueUsernames = {};
      for (UserListModel user in users) {
        if (!uniqueUsernames.contains(user.id)) {
          list_users.add(user);
          uniqueUsernames.add(user.id);
        }
      }
      pageSearch++;
    });
  }

  _delete(String id) {
    print('delete');
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
                    icon: const Icon(Icons.search, color: Colors.grey,),
                    tooltip: 'Search',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Expanded(
              child: FutureBuilder(
              initialData: list_users,
              // future: _getUsers(page, limit),
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
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(5.0),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user.avatar ?? ''),
                            ),
                            title: Text('${user.username} ${user.lastName}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.gender ?? '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  user.email ?? '',
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 20.0,
                                color: Colors.red[300],
                              ),
                              onPressed: () {
                                  _delete(user.id);
                              },
                            ),
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