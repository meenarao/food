import 'package:flutter/material.dart';

class ItemDetailedView extends StatefulWidget {
  @override
  State<ItemDetailedView> createState() => _ItemDetailedViewState();
}

class _ItemDetailedViewState extends State<ItemDetailedView> {
  @override
  Widget build(BuildContext context) {
    final Map? arguments = ModalRoute.of(context)?.settings.arguments as Map?;

    var foodItem = arguments!['foodItem'];
    print(foodItem);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Item'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  child: Column(
                    children: [
                      ClipRRect(
                        // borderRadius: const BorderRadius.vertical(
                        //     top: Radius.circular(20)),
                        child: Image.network(
                          foodItem?['imageUrl'] ??
                              "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8NXx8fGVufDB8fHx8fA%3D%3D&w=1000&q=80",
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  foodItem?['title'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  "  (${foodItem?['selectedOptionSubCat']})",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: foodItem?['selectedOptionSubCat'] ==
                                            "NON-VEG"
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              foodItem?['desc'],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity: ${foodItem?['quantity']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Expiry: ${foodItem?['expiryDate'].split("T")[0]}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Address: ${foodItem?['address']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'No of days available: ${foodItem?['noOfDaysAvailable']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
