import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:flutter_andreas/providers/user.dart';
import '../config/url.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String? username = '';
  late String? password = '';
  bool _isPasswordHidden = true;
  bool _isLoading = false;

  Future<void> submit() async {
    // ignore: avoid_print
    print(username);
    _isLoading = true;
    const url = '${Api.baseUrl}login';
    final response = await http.post(
      Uri.parse(url),
      body: {'username': username, 'password': password},
    );
    // ignore: avoid_print
    print(response.statusCode);
    if (response.statusCode == 200) {
      // final responseData = json.decode(response.body);
       // ignore: use_build_context_synchronously
       Navigator.pushNamed(context, '/home');
    } else {
      // ignore: avoid_print
      print("Gagal");
    }
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
                height: 90,
              ),
              Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 80
              ),
              const SizedBox(
                height: 90,
              ),
              const Center(
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Color.fromARGB(255, 240, 89, 8),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
                )
              ),
              const SizedBox(
                height: 10,
              ),
              const Center(
                child: Text(
                  "Silahkan login gunakan username dan password",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12),
                )
              ),
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
                                          hintText: "username",
                                          hintStyle:
                                              TextStyle(color: Colors.grey.shade300),
                                        ),
                                        validator: (value) => value == null
                                            ? "username wajib diisi"
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
                                        onSaved: (value) => password = value!,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Password",
                                          hintStyle:
                                              TextStyle(color: Colors.grey.shade300),
                                          prefixIcon: Icon(Icons.lock_outline,
                                              color: Colors.grey.shade300),
                                          suffixIcon: IconButton(
                                            color: Colors.grey,
                                            icon: _isPasswordHidden
                                                ? const Icon(
                                                    Icons.visibility_off,
                                                  )
                                                : const Icon(Icons.visibility),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordHidden =
                                                    !_isPasswordHidden;
                                              });
                                            },
                                          ),
                                        ),
                                        obscureText: _isPasswordHidden,
                                        validator: (value) => value == null
                                            ? "Password wajib diisi"
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
                                  "Login",
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