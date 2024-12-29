import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './Screens/home_page.dart';
import './Screens/login_page.dart';
import './Screens/register_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}