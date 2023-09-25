import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food/config.dart';
import 'package:food/shimmer.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key, required this.title});
  final String title;

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final formKey = GlobalKey<FormState>();
  var donatedData = {};
  var isLoading = true;

  static Future<void> checkIfAlreadyLoggedIn(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    if (!isLoggedIn) {
      Navigator.popAndPushNamed(context, "/");
    }
  }

  Future<void> _getDefaultLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final snackBar = SnackBar(
          content: const Text(
            "Location permission isn't enabled",
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
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();

      LatLng latLng = LatLng(position.latitude, position.longitude);
      double latitude = latLng.latitude;
      double longitude = latLng.longitude;

      getItemsDonated({"latitude": latitude, "longitude": longitude});
    } catch (e) {
      print('Error getting default location: $e');
    }
  }

  Future<void> getItemsDonated(dynamic location) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.getString("UserInfo") ?? false;
    var userId = json.decode(userData.toString())['data']['_id'];
    print(location);
    final response = await http.get(
      // ignore: prefer_interpolation_to_compose_strings
      Uri.parse('${Config.apiUrl}/user/getItemsDonated/' +
          userId.toString() +
          "?latitude=${location['latitude']}&longitude=${location['longitude']}"),
    );
    if (response.statusCode == 200) {
      List<dynamic> vegItems = [];
      List<dynamic> nonVegItems = [];

      for (var item in json.decode(response.body)['data']) {
        if (item['selectedOptionSubCat'] == 'VEG') {
          vegItems.add(item);
        } else if (item['selectedOptionSubCat'] == 'NON-VEG') {
          nonVegItems.add(item);
        }
      }

      setState(() {
        donatedData = {"veg": vegItems, "nonVeg": nonVegItems};
        isLoading = false;
      });
    }
  }

  Future<void> _initializeData() async {
    await _getDefaultLocation();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  final List<Tab> tabs = [
    const Tab(text: 'Veg'),
    const Tab(text: 'Non Veg'),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    checkIfAlreadyLoggedIn(context);
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          bottom: TabBar(
            tabs: tabs,
          ),
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
            _getDefaultLocation();
          },
          child: isLoading
              ? ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ShimmeringCard();
                  },
                )
              : TabBarView(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await Future.delayed(Duration(seconds: 1));
                        _getDefaultLocation();
                      },
                      child: ItemListView(
                          itemList: donatedData['veg'] ?? [],
                          callBack: _getDefaultLocation,
                          foodType: "VEG"),
                    ),
                    RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await Future.delayed(const Duration(seconds: 1));
                        _getDefaultLocation();
                      },
                      child: ItemListView(
                          itemList: donatedData['nonVeg'] ?? [],
                          callBack: _getDefaultLocation,
                          foodType: "NON-VEG"),
                    ),
                  ],
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
              await Navigator.pushNamed(context, "/myOrdersUser");
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
              label: 'My orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class ItemListView extends StatelessWidget {
  final List<dynamic> itemList;
  final VoidCallback callBack;
  final String foodType;

  ItemListView(
      {required this.itemList, required this.callBack, required this.foodType});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemList.length,
      itemBuilder: (context, index) {
        if (itemList[index]['selectedOptionSubCat'] == foodType) {
          return FoodItemCard(foodItem: itemList[index], callBack: callBack);
        }
      },
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final dynamic foodItem;
  final VoidCallback callBack;

  FoodItemCard({required this.foodItem, required this.callBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
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
        child: GestureDetector(
          onTap: () async {
            var result = await Navigator.pushNamed(context, "/pick",
                arguments: {"item": foodItem});
            if (result == true) {
              callBack();
            }
          },
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
                    width: 75,
                    height: 85,
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
                            Text(
                              foodItem['desc'],
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.inventory_2,
                                  color: Colors.black45,
                                  size: 12,
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  '${foodItem['quantity']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 14),
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.black45,
                                  size: 12,
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  '${foodItem['distance'].toString().split(".")?[0]} KM',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 14),
                                const Icon(
                                  Icons.hourglass_empty,
                                  color: Colors.black54,
                                  size: 12,
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  '${foodItem['expiryDate'].toString().split("T")?[0]}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            )
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.hail,
                            color: Colors.lightBlue,
                          ),
                          onPressed: () async {
                            var result = await Navigator.pushNamed(
                                context, "/pick",
                                arguments: {"item": foodItem});
                            if (result == true) {
                              callBack();
                            }
                          },
                        )
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
