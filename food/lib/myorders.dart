import 'dart:convert';
import 'package:food/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyOrdersUser extends StatefulWidget {
  const MyOrdersUser({super.key});

  @override
  State<MyOrdersUser> createState() => _MyOrdersUserState();
}

class _MyOrdersUserState extends State<MyOrdersUser> {
  var myOrders = [];

  Future<void> getItemsPick() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.getString("UserInfo") ?? false;
    var userId = json.decode(userData.toString())['data']['_id'];
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/user/getItemsPicked/$userId'),
    );
    if (response.statusCode == 200) {
      var result = json.decode(response.body)['data'];
      setState(() {
        myOrders = result.reversed.toList();
      });
    }
  }

  Future<void> _initializeData() async {
    await getItemsPick();
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
          title: const Text("My Orders"),
        ),
        body: ItemListView(itemList: myOrders));
  }
}

class ItemListView extends StatelessWidget {
  final List<dynamic> itemList;

  ItemListView({required this.itemList});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemList.length,
      itemBuilder: (context, index) {
        if (itemList[index]['item'] != null)
          return FoodItemCard(
              foodItem: itemList[index]['item'], pickUp: itemList[index]);
      },
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final dynamic foodItem;
  final dynamic pickUp;

  const FoodItemCard({super.key, required this.foodItem, required this.pickUp});

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
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                      Text(
                        pickUp['status'],
                        style: TextStyle(
                          fontSize: 16,
                          color: pickUp['status'] == 'PENDING'
                              ? Colors.blue
                              : pickUp['status'] == 'ACCEPTED'
                                  ? Colors.green
                                  : Colors.red,
                        ),
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
