import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserSignup extends StatefulWidget {
  @override
  _UserSignupState createState() => _UserSignupState();
}

class _UserSignupState extends State<UserSignup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static Future<void> setLoggedIn(bool loggedIn, Map? data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", loggedIn);
    await prefs.setString("UserInfo", json.encode(data));
  }

  Future<void> _registerUser() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/user/signup'),
      body: {'email': email, "password": password, "name": name},
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      setLoggedIn(true, responseData);
      final snackBar = SnackBar(
        content: const Text(
          "User registered successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        action: SnackBarAction(
          label: 'Close',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // ignore: use_build_context_synchronously
      Navigator.popAndPushNamed(context, "/userDashboard");
    } else {
      var responseData = json.decode(response.body);
      String message = responseData['message'] ?? 'Please try later';
      final snackBar = SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        action: SnackBarAction(
          label: 'Close',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      throw Exception('Failed to submit form: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Signup'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputStyles.inputDecoration(label: "Name"),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                  ],
                  validator: (value) {
                    if (value == '') {
                      return 'Please enter name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputStyles.inputDecoration(label: "Email"),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                        RegExp(r'[^a-zA-Z0-9@._]')),
                  ],
                  validator: (value) {
                    if (value == '') {
                      return 'Please enter an email address.';
                    } else if (!value!.contains("@") || !value!.contains(".")) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputStyles.inputDecoration(label: "Password"),
                  obscureText: true,
                  validator: (value) {
                    if (value == '' ||
                        !value!.contains(RegExp(r'[A-Z]')) ||
                        !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')) ||
                        !value.contains(RegExp(r'[0-9]'))) {
                      return 'Please enter a valid password';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: const Text(
                    "Password should contain uppercase, number and special character.",
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _registerUser();
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      foregroundColor: MaterialStateProperty.all(Colors.white)),
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
