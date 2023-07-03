// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/url.dart';



class UserCreatePage extends StatefulWidget {
  const UserCreatePage({Key? key}) : super(key: key);

  @override
  UserCreatePageState createState() => UserCreatePageState();
}

class UserCreatePageState extends State<UserCreatePage> {

  final List data = [
    {
      "title": "Male",
      "data": "Male",
    },
    {
      "title": "Female",
      "data": "Female",
    },
  ];

  late String? dataAwal = '';

  @override
  void initState() {
    dataAwal = data[0]["data"];
    super.initState();
  }
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String? username = '';
  late String? last_name = '';
  late String? email = '';
  late String? gender = '';
  bool _isLoading = false;

  Future<void> submit() async {
    // ignore: avoid_print
    print(username);
    _isLoading = true;
    const url = '${Api.baseUrl}login';
    final response = await http.post(
      Uri.parse(url),
      body: {'user': username, 'last_name': last_name, 'email': email, 'gender': gender},
    );
    // ignore: avoid_print
    print(response);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == 1) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/home');
      }
    } else {
      // ignore: avoid_print
      print("Gagal");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create User"),
        backgroundColor: Colors.orange.shade900,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color.fromRGBO(143, 148, 251, .2),
                                        blurRadius: 20.0,
                                        offset: Offset(0, 10))
                                  ]),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey.shade100),
                                      ),
                                    ),
                                    child: Center(
                                      child: TextFormField(
                                        onSaved: (value) => username = value!,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.person,
                                              color: Colors.grey.shade300),
                                          hintText: "First Name",
                                          hintStyle:
                                              TextStyle(color: Colors.grey.shade300),
                                        ),
                                        validator: (value) => value == null
                                            ? "First Name is required"
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey.shade100),
                                      ),
                                    ),
                                    child: Center(
                                      child: TextFormField(
                                        onSaved: (value) => last_name = value!,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.person,
                                              color: Colors.grey.shade300),
                                          hintText: "Last Name",
                                          hintStyle:
                                              TextStyle(color: Colors.grey.shade300),
                                        ),
                                        validator: (value) => value == null
                                            ? "Last Name is required"
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey.shade100),
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: 200,
                                      child: DropdownButton<String>(
                                        value: dataAwal,
                                        items: data
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e['data'] as String,
                                                child: Text("${e['title']}"),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            dataAwal = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey.shade100),
                                      ),
                                    ),
                                    child: Center(
                                      child: TextFormField(
                                        onSaved: (value) => email = value!,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.mail,
                                              color: Colors.grey.shade300),
                                          hintText: "Email",
                                          hintStyle:
                                              TextStyle(color: Colors.grey.shade300),
                                        ),
                                        validator: (value) => value == null
                                            ? "Email is required"
                                            : null,
                                      ),
                                    ),
                                  ),
                                  
                                ],
                              ),
                            ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: _isLoading == true ?Colors.orange.shade900 : Colors.orange.shade900,
                            ),
                            child: Center(
                              child: TextButton(
                                onPressed: () => submit(),
                                child: const Text(
                                  "Save",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 70,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}