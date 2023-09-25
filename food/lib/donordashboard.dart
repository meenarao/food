import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food/config.dart';
import 'package:food/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key, required this.title});
  final String title;

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final formKey = GlobalKey<FormState>();
  var donatedData = [];
  var isLoading = true;

  static Future<void> checkIfAlreadyLoggedIn(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    if (!isLoggedIn) {
      Navigator.popAndPushNamed(context, "/");
    }
  }

  Future<void> getItemsDonated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = await prefs.getString("UserInfo") ?? false;
    var userId = json.decode(userData.toString())!['data']!['_id'];
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/donor/getItemsDonated/' + userId.toString()),
    );
    if (response.statusCode == 200) {
      setState(() {
        donatedData = json.decode(response.body)['data'];
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

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    checkIfAlreadyLoggedIn(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.popAndPushNamed(context, "/");
            },
            child: const Row(
              children: [
                Icon(Icons.power_settings_new),
                SizedBox(width: 8.0), // Add spacing between icon and text
                Text('Logout'),
              ],
            ),
          )
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              isLoading = true;
            });
            await Future.delayed(Duration(seconds: 1));
            getItemsDonated();
          },
          child: isLoading
              ? ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ShimmeringCard();
                  },
                )
              : ItemListView(
                  itemList: donatedData,
                  callback: () {
                    setState(() {
                      isLoading = true;
                    });
                    getItemsDonated();
                  })),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          var result = await Navigator.pushNamed(context, "/addItemFormDoner");
          if (result == true) {
            getItemsDonated();
          }
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.add)],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            await Navigator.pushNamed(context, "/donors/pickups");
            setState(() {
              _currentIndex = 0;
            });
          } else if (index == 2) {
            await Navigator.pushNamed(context, "/profile");
            setState(() {
              _currentIndex = 0;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ItemListView extends StatelessWidget {
  final List<dynamic> itemList;
  final VoidCallback callback;

  ItemListView({required this.itemList, required this.callback});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemList.length,
      itemBuilder: (context, index) {
        return FoodItemCard(foodItem: itemList[index], callback: callback);
      },
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final dynamic foodItem;
  final VoidCallback callback;

  const FoodItemCard(
      {super.key, required this.foodItem, required this.callback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "/itemDetailedView",
              arguments: {"foodItem": foodItem});
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.25),
                spreadRadius: 0.25,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(10)),
                  child: Image.network(
                    foodItem['imageUrl'] ??
                        "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8NXx8fGVufDB8fHx8fA%3D%3D&w=1000&q=80",
                    width: 100,
                    height: 105,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  foodItem['title'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "  (${foodItem['selectedOptionSubCat']})",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: foodItem['selectedOptionSubCat'] ==
                                            "NON-VEG"
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              foodItem['desc'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Quantity: ${foodItem['quantity']}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        Row(
                          children: [
                            if (foodItem['pickups'].length > 0)
                              IconButton(
                                icon: const Icon(
                                  Icons.hail,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  var result = await Navigator.pushNamed(
                                      context, "/pickUpsManagement",
                                      arguments: {"item": foodItem});
                                  if (result == true) {
                                    callback();
                                  }
                                },
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                final response = await http.delete(
                                  Uri.parse(
                                      '${Config.apiUrl}/deleteItem/${foodItem['_id']}'),
                                );
                                if (response.statusCode == 200) {
                                  final snackBar = SnackBar(
                                    content: const Text(
                                      'Item deleted successfully!',
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
                                  callback();
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
