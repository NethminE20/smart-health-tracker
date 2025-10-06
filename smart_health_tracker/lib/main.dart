import 'package:flutter/material.dart';
// import 'screens/predict_screen.dart';
// import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
//import 'screens/signup_screen.dart';

void main() {
  runApp(const HealthApp());
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Health Tracker",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}
