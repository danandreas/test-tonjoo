import 'package:flutter/material.dart';
import 'package:flutter_andreas/pages/home.dart';
import 'package:flutter_andreas/pages/splash.dart';
import 'pages/login.dart';
import 'package:isar/isar.dart';


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MyApp> {
  bool isAuthenticated = false; 

  void authenticateUser() {
    isAuthenticated = false;
  }

  @override
  void initState() {
    super.initState();
    authenticateUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tonjoo',
      // home: isAuthenticated ? const LoginPage() : const LoginPage(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const SplashPage());
      },

    );
  }
}

late Isar isar;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Hive.initFlutter();
  // Hive.registerAdapter(UserListModelHiveAdapter()); // Register the adapter
  // await Hive.openBox<UserListModelHive>('users');
  runApp(const MyApp());
}



