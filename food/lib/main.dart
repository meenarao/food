import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food/additemdonor.dart';
import 'package:food/config.dart';
import 'package:food/donordashboard.dart';
import 'package:food/itemview.dart';
import 'package:food/mapsetup.dart';
import 'package:food/myorders.dart';
import 'package:food/pickup.dart';
import 'package:food/pickupmanagement.dart';
import 'package:food/pickupmanagementall.dart';
import 'package:food/profile.dart';
import 'package:food/userdashboard.dart';
import 'package:food/usersingup.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Doner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
            backgroundColor: Colors.white, primarySwatch: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => const MyHomePage(title: 'Food Doner'),
        'donorDashboard': (context) =>
            const DonorDashboard(title: "Your donations"),
        '/addItemFormDoner': (context) =>
            const AddItemDonor(title: "Add an item"),
        '/userDashboard': (context) =>
            const UserDashboard(title: "Donations list"),
        '/userSignup': (context) => UserSignup(),
        '/pick': (context) => PickUp(),
        '/mapsetup': (context) => LocationPicker(),
        '/pickUpsManagement': (context) => const PickUpManagement(),
        '/myOrdersUser': (context) => const MyOrdersUser(),
        '/itemDetailedView': (context) => ItemDetailedView(),
        '/donors/pickups':  (context) => const PickUpManagementAll(),
        '/profile': (context) => Profile()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String email = '';
  String password = '';
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  static Future<void> setLoggedIn(bool loggedIn, Map? data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", loggedIn);
    await prefs.setString("UserInfo", json.encode(data));
  }

  Future<void> formSubmit() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/login'),
        body: {'email': email, "password": password},
      );

      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        await setLoggedIn(true, responseData);

        if (responseData['data']['role'] == "ADMIN") {
          Navigator.popAndPushNamed(context, "donorDashboard");
        } else if (responseData['data']['role'] == "USER") {
          Navigator.popAndPushNamed(context, "/userDashboard");
        }
      } else {
        setLoggedIn(true, {});
        var responseData = json.decode(response.body);
        print(responseData);
        throw Exception('Failed to submit form: ${response.statusCode}');
      }
    } catch (err) {
      final snackBar = SnackBar(
        content: const Text(
          'No User found!',
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
    }
  }

  static Future<void> checkIfAlreadyLoggedIn(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    var userData = prefs.getString("UserInfo") ?? "";
    if (isLoggedIn && json.decode(userData)['data']['role'] == "ADMIN") {
      Navigator.popAndPushNamed(context, "donorDashboard");
    } else if (isLoggedIn && json.decode(userData)['data']['role'] == "USER") {
      Navigator.popAndPushNamed(context, "/userDashboard");
    }
  }

  @override
  Widget build(BuildContext context) {
    checkIfAlreadyLoggedIn(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Login',
                style: TextStyle(fontSize: 25),
              ),
              TextField(
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputStyles.inputDecoration(label: "Email"),
              ),
              const SizedBox(
                height: 8,
              ),
              TextField(
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: InputStyles.inputDecoration(label: "Password"),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: formSubmit,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  minimumSize:
                      MaterialStateProperty.all(const Size(double.infinity, 0)),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 0)),
                ),
                child: const Text('Submit'),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Not a user?"),
                  TextButton(
                    onPressed: () async {
                      Navigator.pushNamed(context, "/userSignup");
                    },
                    child: const Text("Signup"),
                  ),
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
