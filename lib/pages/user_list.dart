import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/url.dart';


class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {

  Future<List<User>> _getUsers() async {
    const url = '${Api.baseUrl}users';
    var data = await http.get(Uri.parse(url));
    var jsonData = json.decode(data.body);
    List<User> users = [];
    for(var u in jsonData){
      User user = User(u["id"] ?? "", u["username"] ?? "", u["gender"] ?? "", u["last_name"] ?? "", u["email"] ?? "", u["avatar"] ?? "");
      users.add(user);
    }
    // ignore: avoid_print
    print(users.length);
    return users;

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
                return const Text("Loading...");
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
                      title: Text(snapshot.data[id].username + ' - ' + snapshot.data[id].lastname),
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
  final String lastname;
  final String email;
  // ignore: prefer_void_to_null, avoid_init_to_null
  String? avatar = null;

  User(this.id, this.username, this.gender, this.lastname, this.email, this.avatar);

}