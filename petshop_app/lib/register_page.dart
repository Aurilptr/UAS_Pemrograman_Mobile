import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    // 1. LOGGING CLIENT
    print("[CLIENT] REGISTER BUTTON CLICKED");
    print("[CLIENT] Data: Name=${_nameController.text}, Email=${_emailController.text}");

    setState(() { _isLoading = true; });
 
    const String apiUrl = 'http://192.168.101.12:5000/register'; 

    try {
      print("[CLIENT] SENDING REQUEST TO: $apiUrl"); 

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      print("[CLIENT] RESPONSE STATUS: ${response.statusCode}"); 
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // 2. LOGGING CLIENT: Berhasil
        print("[CLIENT] REGISTER SUCCESS: ${data['message']}");
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: pastelGreen),
        );
        Navigator.pop(context); 
      } else {
        // 3. LOGGING CLIENT: Gagal dari Server (misal email kembar)
        print("[CLIENT] REGISTER FAILED: ${data['message']}");
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: pastelPink),
        );
      }
    } catch (e) {
      // 4. LOGGING CLIENT: Error Koneksi (Server mati / IP salah)
      print("[CLIENT] REGISTER EXCEPTION: $e");
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isLoading = false; });
      print("[CLIENT] REGISTER PROCESS FINISHED"); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralWhite,
      appBar: AppBar(title: const Text("Daftar Akun")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 80, color: pastelBlue),
            const SizedBox(height: 20),
            Text("Gabung Pawmate", style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: pastelBlue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person, color: pastelBlue)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email, color: pastelBlue)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock, color: pastelBlue)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(backgroundColor: pastelBlue),
                    child: const Text("DAFTAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}