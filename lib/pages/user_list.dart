import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/url.dart';
import 'package:flutter_andreas/local_db/localUser.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';


class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  late String textLoading = 'Loading...';


  Future<dynamic> _getUsers() async {
    try {
      const url = '${Api.baseUrl}users';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200) {

         var dir = await getApplicationDocumentsDirectory();
          var isar = await Isar.open(
            [LocalUserSchema],
            directory: dir.path,
          );
          await isar.writeTxn(() async {
            await isar.localUsers.clear();
          });
          await isar.localUsers.buildQuery().deleteAll();
        List<User> users = [];
        for(var u in jsonData){
          User user = User(u["id"] ?? "", u["username"] ?? "", u["gender"] ?? "", u["last_name"] ?? "", u["email"] ?? "", u["avatar"] ?? "");
          users.add(user);
        }

         final List<dynamic> jsonList = jsonData;
          // final isar = Isar.getInstance();
          final persons = isar.localUsers;

          await isar.writeTxn(() async {
            for (var json in jsonList) {
              final person = LocalUser()
                ..id = json['id']
                ..username = json['username']
                ..lastName = json['last_name']
                ..email = json['email']
                ..gender = json['gender']
                ..avatar = json['avatar'];
              await persons.put(person);
            }
          });
          await isar.close();
          textLoading = 'Load form server database...';
          return users;
      } else {
        return getPersonsFromIsar();
      }
    } catch (e) {
      return getPersonsFromIsar();
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
            future: _getUsers(),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if(snapshot.data == null){
                return Center(
                  child: Text(textLoading));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int id) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          snapshot.data[id].avatar
                        ),
                      ),
                      title: Text(snapshot.data[id].username + ' - ' + snapshot.data[id].lastName),
                      // subtitle: Text(snapshot.data[id].email)
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data[id].gender,
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            snapshot.data[id].email,
                          ),
                        ],
                      ),
                    );
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

  User(this.id, this.username, this.gender, this.lastName, this.email, this.avatar);
}