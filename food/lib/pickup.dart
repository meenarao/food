// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food/config.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PickUp extends StatefulWidget {
  @override
  _PickUpState createState() => _PickUpState();
}

class _PickUpState extends State<PickUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  var _pickedDate;

  void _submitForm(dynamic foodItem) async {
    if (_formKey.currentState!.validate()) {
      if (_pickedDate == null) {
        final snackBar = SnackBar(
          content: const Text(
            'Please pick a date.',
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
      } else {
        String name = _nameController.text;
        String email = _emailController.text;
        String mobile = _mobileController.text;
        String pickupDateTime = '${_pickedDate!}';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var userData = await prefs.getString("UserInfo") ?? false;
        var userId = json.decode(userData.toString())!['data']!['_id'];
        final response = await http.post(
          Uri.parse('${Config.apiUrl}/user/pickup/${foodItem['_id']}'),
          body: {
            'email': email,
            'userId': userId,
            "name": name,
            "mobile": mobile,
            "pickUpDateTime": pickupDateTime
          },
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
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    var foodItem = arguments?['item'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick up'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FoodItemCard(foodItem: foodItem),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputStyles.inputDecoration(label: "Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                  ],
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
                  controller: _mobileController,
                  decoration: InputStyles.inputDecoration(
                      label: "Mobile Number (Optional)"),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _selectDate(),
                  child: const Text('Select Pick up Date and Time'),
                ),
                Text(
                  "Selected Pick up date: ${_pickedDate ?? "N/A"} ",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _submitForm(foodItem);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    minimumSize: MaterialStateProperty.all(
                        const Size(double.infinity, 0)),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 0)),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime dateTime = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, pickedTime.hour, pickedTime.minute);
        String formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
        setState(() {
          _pickedDate = formattedDateTime;
        });
      }
    }
  }
}

class FoodItemCard extends StatelessWidget {
  final dynamic foodItem;

  FoodItemCard({required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              foodItem['imageUrl'] ??
                  "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8NXx8fGVufDB8fHx8fA%3D%3D&w=1000&q=80",
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
            child: Text(
              foodItem['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      foodItem['desc'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Quantity: ${foodItem['quantity']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Expiry: ${foodItem['expiryDate'].split("T")[0]}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address: ${foodItem['address']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'No of days available: ${foodItem['noOfDaysAvailable']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Distance: ${(foodItem['distance']).toString().split(".")[0]} KM',
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
