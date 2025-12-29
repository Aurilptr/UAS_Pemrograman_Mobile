import 'package:flutter/material.dart';
import 'theme.dart';
import 'splash_screen.dart';
import 'login_page.dart'; 

void main() {
  runApp(const PawmateApp());
}

class PawmateApp extends StatelessWidget {
  const PawmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pawmate',
      theme: pawmateTheme, 
      home: const SplashScreen(), 
    );
  }
}