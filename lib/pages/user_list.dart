import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';


class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {

  Future<List<User>> _getUsers() async {
    const url = "https://test-android.tongkolspace.com/users";
    var data = await http.get(Uri.parse(url));

    var jsonData = json.decode(data.body);

    List<User> users = [];

    for(var u in jsonData){

      User user = User(u["id"], u["username"], u["email"], u["avatar"]);

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
                      title: Text(snapshot.data[id].username),
                      subtitle: Text(snapshot.data[id].email)
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
  final String email;
  final String avatar;

  User(this.id, this.username, this.email, this.avatar);

}