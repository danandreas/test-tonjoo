import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../config/url.dart';

// ignore: constant_identifier_names
enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserProvider with ChangeNotifier {

  Status _status = Status.Uninitialized;
  late String _token;

  Status get status => _status;
  String get token => _token;

  initAuthProvider() async {
    String? token = await getToken();

    if (token != '') {
      _token = token!;
      _status = Status.Authenticated;
    } else {
      _status = Status.Unauthenticated;
    }
    notifyListeners();
  }

  // LOGIN
  Future<Map<String, dynamic>> login(String username, String password) async {
    _status = Status.Authenticating;
    notifyListeners();
    const url = '${Api.baseUrl}login';
    final response = await http.post(Uri.parse(url), body: {
      'username': username,
      'password': password
    });
    final apiResponse = json.decode(response.body);
    // ignore: avoid_print
    print(url);

    // if (response.data.cussess == 201) {
    //   _status = Status.Authenticated;
    //   _token = apiResponse['access_token'];
    //   await storeUserData(apiResponse);
    //   notifyListeners();
    //   dataResponse = {
    //     'type': 'success',
    //     'title': 'Masuk',
    //     'message': apiResponse['message']
    //   };
    //   return dataResponse;
    // } else if (response.statusCode == 401) {
    //   _status = Status.Unauthenticated;
    //   print('Kombinasi username dan password salah');
    //   notifyListeners();
    //   dataResponse = {
    //     'type': 'error',
    //     'title': 'Gagal',
    //     'message': apiResponse['message']
    //   };
    //   return dataResponse;
    // }

    // _status = Status.Unauthenticated;
    // print('Server Error');
    // notifyListeners();
    // dataResponse = {
    //   'type': 'error',
    //   'title': 'Error',
    //   'message': 'Server Error di Provider'
    // };
    // return dataResponse;
    return apiResponse;
  }

  // storeUserData(apiResponse) async {
  //   SharedPreferences storage = await SharedPreferences.getInstance();
  //   await storage.setString('token', apiResponse['access_token']);
  //   await storage.setString('id', apiResponse['customer']['id']);
  //   await storage.setString('name', apiResponse['customer']['name']);
  // }

  Future<String?> getToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String? token = storage.getString('token');
    return token;
  }

  // Future<String> getName() async {
  //   SharedPreferences storage = await SharedPreferences.getInstance();
  //   String name = storage.getString('name');
  //   return name;
  // }

  // Future<String> getId() async {
  //   SharedPreferences storage = await SharedPreferences.getInstance();
  //   String id = storage.getString('id');
  //   return id;
  // }
}
