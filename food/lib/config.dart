// config.dart

import 'package:flutter/material.dart';

class Config {
  static const String apiUrl = 'https://vast-pear-sockeye-kilt.cyclic.app';
  // static const String apiUrl =
  //     'https://super-duper-spoon-v4xq5jvq99r3p9v7-3000.app.github.dev';
  static const String GOOGLE_API_KEY =
      'AIzaSyBrHDWr-u_ZSZ-L3QzbHMafBpqDbcKp5TY';
}

class InputStyles {
  static InputDecoration inputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black26),
        borderRadius: BorderRadius.circular(8.0),
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    );
  }
}
