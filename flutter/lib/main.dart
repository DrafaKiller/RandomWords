import 'package:flutter/material.dart';

import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);
  static var urlREST = Uri.parse('http://10.0.2.2:3000/');
  static String? token;
  static int? userId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Words',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),   
      home: const LoginPage()
    );
  }
}