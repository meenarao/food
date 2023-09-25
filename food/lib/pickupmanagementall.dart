import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PickUpManagementAll extends StatefulWidget {
  const PickUpManagementAll({super.key});

  @override
  State<PickUpManagementAll> createState() => _PickUpManagementAllState();
}

class _PickUpManagementAllState extends State<PickUpManagementAll> {
  var pickups = [];
  var isLoading = true;
  Future<void> getItemsDonated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = await prefs.getString("UserInfo") ?? false;
    var userId = json.decode(userData.toString())!['data']!['_id'];
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/donor/getPickUps/' + userId.toString()),
    );
    if (response.statusCode == 200) {
      setState(() {
        pickups = json.decode(response.body)['data'];
        isLoading = false;
      });
    }
  }

  Future<void> _initializeData() async {
    await getItemsDonated();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Pick up Management"),
        ),
        body: ListView.builder(
          itemCount: pickups.length,
          itemBuilder: (context, index) {
            var pickup = pickups[index];

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                title: Text(
                  '${pickup["name"]} - ${pickup["item"]["title"]}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Pickup Time: ${pickup['pickUpDateTime'].toString()}',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (pickup['status'] == 'PENDING')
                      IconButton(
                        icon: const Icon(Icons.check),
                        color: Colors.green,
                        onPressed: () async {
                          final response = await http.get(
                            Uri.parse(
                                '${Config.apiUrl}/donor/pickup/${pickup['_id']}?status=ACCEPTED'),
                          );
                          if (response.statusCode == 200) {
                            final snackBar = SnackBar(
                              content: const Text(
                                'Congratulations! Pickup updated.',
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
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Navigator.pop(context, true);
                          } else {
                            final snackBar = SnackBar(
                              content: const Text(
                                'Item unavailable!',
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
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                      ),
                    if (pickup['status'] == 'PENDING')
                      IconButton(
                        icon: Icon(Icons.close),
                        color: Colors.red,
                        onPressed: () async {
                          final response = await http.get(
                            Uri.parse(
                                '${Config.apiUrl}/donor/pickup/${pickup['_id']}?status=REJECTED'),
                          );
                          if (response.statusCode == 200) {
                            final snackBar = SnackBar(
                              content: const Text(
                                'Pickup rejected.',
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
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Navigator.pop(context, true);
                          } else {
                            final snackBar = SnackBar(
                              content: const Text(
                                'Item unavailable!',
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
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                      ),
                    if (pickup['status'] != 'PENDING')
                      Text(
                        pickup['status'],
                        style: TextStyle(
                          fontSize: 16,
                          color: pickup['status'] == 'PENDING'
                              ? Colors.blue
                              : pickup['status'] == 'ACCEPTED'
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}

class FoodItem extends StatelessWidget {
  final dynamic foodItem;

  const FoodItem({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
