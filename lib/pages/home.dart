import 'package:flutter/material.dart';
import 'package:flutter_andreas/pages/login.dart';
import 'package:flutter_andreas/pages/user_create.dart';
import 'package:flutter_andreas/pages/user_list.dart';
import 'package:flutter_andreas/pages/web_view.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../config/url.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GetStorage box = GetStorage();
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

  void logout() {
    box.write('token', null);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  Future<bool?> _showLogoutConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
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
        onTap: (value) async {
          if (value == 2) {
            bool? confirmed = await _showLogoutConfirmationDialog();
            if (confirmed == true) {
              logout(); // Call the logout function when "Logout" tab is tapped and confirmed
            }
          } else {
            setState(() {
              index = value;
            });
          }
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
            icon: Icon(Icons.logout),
            label: "Logout",
          ),
        ],
      ),
    );
  }
}