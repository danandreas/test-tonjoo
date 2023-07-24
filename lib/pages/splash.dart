import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_andreas/pages/home.dart';
import 'package:flutter_andreas/pages/login.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../config/url.dart';
import 'package:flutter_andreas/config/local_db.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import '../local_db/localUser.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
  
}

class SplashPageState extends State<SplashPage> {
  GetStorage box = GetStorage();
  
  late Isar isarUsers;

  initialDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final isarUser = await Isar.open(
      [LocalUserSchema],
      name: "db_user",
      directory: dir.path,
    );
    isarUsers = isarUser;
  }

  void redirectPage() async {
    var dataToken = await box.read('token');
    Future.delayed(const Duration(seconds: 2), () {
      if (dataToken != null) {
        Navigator.pushNamed(context, '/home');
      } else {
        Navigator.pushNamed(context, '/login');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initialDb();
    redirectPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 300,
              ),
              Image.asset('assets/images/logo.png', width: 80, height: 80),
              const SizedBox(
                height: 90,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
