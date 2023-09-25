// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:food/config.dart';
import 'package:food/mapsetup.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class AddItemDonor extends StatefulWidget {
  const AddItemDonor({super.key, required this.title});
  final String title;

  @override
  State<AddItemDonor> createState() => _AddItemDonorState();
}

class _AddItemDonorState extends State<AddItemDonor> {
  final formKey = GlobalKey<FormState>();
  var selectedOption = "FOOD";
  var selectedOptionSubCat = "VEG";
  var title;
  var desc;
  var quantity;
  var expiryDate;
  var pickUpDateTime;
  var address;
  var noOfDaysAvailable;
  var user;
  File? _selectedImage;
  var imageUrl;
  var location;

  TextEditingController _expirydateController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  Future<void> _pickImage() async {
    await _requestGalleryPermission();
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _requestGalleryPermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isPermanentlyDenied) {
      // openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> uploadImage(File? imageFile) async {
    try {
      String url = '${Config.apiUrl}/uploadImage';
      String fileName = imageFile!.path.split('/').last;
      ;
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        'image':
            await MultipartFile.fromFile(imageFile!.path, filename: fileName),
      });
      Response response = await dio.post(url, data: formData);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  onLocationSelected(value) {
    double latitude = value.latitude; // Extract latitude (18.745946912469872)
    double longitude = value.longitude; // Extract longitude (79.50459491461515)

    setState(() {
      location = [latitude, longitude];
    });
  }

  bool isButtonDisabled = false;

  Future<void> addItemAPI() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userData = prefs.getString("UserInfo") ?? false;
      if (userData != false) {
        if (_selectedImage != null) {
          var image_url = await uploadImage(_selectedImage);
          final response = await http.post(
            Uri.parse('${Config.apiUrl}/addItemDoner'),
            body: {
              "selectedOption": selectedOption,
              "selectedOptionSubCat": selectedOptionSubCat,
              "title": title,
              "desc": desc,
              "quantity": quantity,
              "expiryDate": expiryDate.toString(),
              "pickUpDateTime": pickUpDateTime.toString(),
              "address": address,
              "noOfDaysAvailable": noOfDaysAvailable,
              "user": userData,
              "imageUrl": image_url['imageUrl'].toString(),
              "location": location.toString(),
            },
          );

          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            final snackBar = SnackBar(
              content: const Text(
                'You have successfully donated',
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
            setState(() {
              isButtonDisabled = false;
            });
            final snackBar = SnackBar(
              content: const Text(
                'Please try later',
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
        } else {
          setState(() {
            isButtonDisabled = false;
          });
          final snackBar = SnackBar(
            content: const Text(
              'Please upload an image',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.yellow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            action: SnackBarAction(
              label: 'Close',
              textColor: Colors.black,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (error) {
      setState(() {
        isButtonDisabled = false;
      });
      final snackBar = SnackBar(
        content: const Text(
          'Please enter correct information.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.camera_alt,
                        size: 50,
                      ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 20, 10, 0),
              child: DropdownButton<String>(
                value: selectedOption,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedOption = newValue;
                  }
                },
                isExpanded: true,
                items: ["FOOD"].map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
              child: DropdownButton<String>(
                value: selectedOptionSubCat,
                onChanged: (newValue) {
                  if (newValue != null) {
                    // Update the selectedOption variable and trigger a rebuild
                    setState(() {
                      selectedOptionSubCat = newValue;
                    });
                  }
                },
                isExpanded: true,
                items: ["VEG", "NON-VEG"].map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    title = val;
                  });
                },
                keyboardType: TextInputType.text,
                decoration: InputStyles.inputDecoration(label: "Name"),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    desc = val;
                  });
                },
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                textInputAction: TextInputAction.newline,
                decoration: InputStyles.inputDecoration(label: "Description"),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    quantity = val;
                  });
                },
                keyboardType: TextInputType.number,
                decoration: InputStyles.inputDecoration(label: "Quantity"),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _expirydateController,
                    keyboardType: TextInputType.none,
                    decoration:
                        InputStyles.inputDecoration(label: "Expiry date"),
                    onChanged: (value) {
                      setState(() {
                        expiryDate = value;
                      });
                    },
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );

                      if (selectedDate != null) {
                        setState(() {
                          expiryDate = selectedDate;
                          _expirydateController.text =
                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _dateController,
                    keyboardType: TextInputType.none,
                    decoration: InputStyles.inputDecoration(
                        label: "Pick up Date and Time"),
                    onChanged: (value) {},
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );

                      if (selectedDate != null) {
                        TimeOfDay? selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (selectedTime != null) {
                          DateTime dateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );

                          setState(() {
                            pickUpDateTime =
                                "${dateTime.toLocal()}".split('.')[0];
                            _dateController.text =
                                "${dateTime.toLocal()}".split('.')[0];
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    address = val;
                  });
                },
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                textInputAction: TextInputAction.newline,
                decoration:
                    InputStyles.inputDecoration(label: "Address & eir code"),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    noOfDaysAvailable = val;
                  });
                },
                keyboardType: TextInputType.number,
                decoration:
                    InputStyles.inputDecoration(label: "No. of days available"),
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(10, 12, 10, 0),
                child: TextButton(
                  onPressed: () async {
                    var result =
                        await Navigator.pushNamed(context, "/mapsetup");
                    if (result != null) {
                      final snackBar = SnackBar(
                        content: const Text(
                          'Location selected!',
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
                    }
                    onLocationSelected(result);
                  },
                  style: TextButton.styleFrom(
                      backgroundColor:
                          location != null ? Colors.green : Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0)),
                  child: const Text("Select location"),
                )),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 12, 10, 0),
              child: TextButton(
                onPressed: isButtonDisabled
                    ? null
                    : () async {
                        setState(() {
                          isButtonDisabled = true;
                        });
                        await addItemAPI();
                      },
                style: TextButton.styleFrom(
                    backgroundColor:
                        isButtonDisabled ? Colors.grey : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 0)),
                child: const Text("Submit"),
              ),
            )
          ],
        ),
      )),
    );
  }
}
