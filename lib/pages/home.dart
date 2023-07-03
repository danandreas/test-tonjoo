import 'package:flutter/material.dart';
import 'package:flutter_andreas/pages/user_create.dart';
import 'package:flutter_andreas/pages/user_list.dart';
import 'package:flutter_andreas/pages/web_view.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../config/url.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int index;

  List showWidget = [
    const Center(
      child: UserListPage(),
    ),
    const Center(
      child: UserCreatePage(),
    ),
    const Center(
      child: WebviewPage(),
    ),
  ];

  @override
  void initState() {
    index = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showWidget[index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.orange.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black26,
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: "Add New",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.language),
            label: "Web View",
          ),
        ],
      ),
    );
  }
}