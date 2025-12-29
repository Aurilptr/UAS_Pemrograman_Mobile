import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'theme.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Mengatur Timer selama 3 detik
    Timer(const Duration(seconds: 3), () {
      // Pindah ke LoginPage setelah 3 detik
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 223, 223), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pets_rounded,
              size: 100,
              color: Color(0xFF64B5F6), 
            ),
            const SizedBox(height: 20),
            const Text(
              "Pawmate",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Kebutuhan Anabul Terbaik",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64B5F6)),
            ),
          ],
        ),
      ),
    );
  }
}