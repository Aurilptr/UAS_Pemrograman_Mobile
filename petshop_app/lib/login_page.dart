import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'theme.dart';
import 'register_page.dart';
import 'main_page.dart';
import 'admin_home_page.dart'; // WAJIB: Pastikan file ini ada

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    // 1. LOGGING: Input User (Pakai [AUTH] karena belum tahu siapa yg login)
    print("[AUTH] LOGIN ATTEMPT: Email=${_emailController.text}");
    
    setState(() { _isLoading = true; });

    // Ganti IP sesuai device kamu (127.0.0.1 untuk Web, 10.0.2.2 untuk Emulator)
    const String apiUrl = 'http://127.0.0.1:5000/login'; 

    try {
      print("[AUTH] CONNECTING TO: $apiUrl");
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      print("[AUTH] RESPONSE STATUS: ${response.statusCode}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = data['data'];
        String role = user['role']; // Ambil role (admin/client)
        
        // --- LOGIC DINAMIS: UBAH PREFIX LOG BERDASARKAN ROLE ---
        String logPrefix = role == 'admin' ? "[ADMIN]" : "[CLIENT]";
        
        // 2. LOGGING SUKSES
        print("$logPrefix LOGIN SUCCESS: User ID ${user['id']} ($role)");
        
        // Simpan ke Shared Preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', user['id']);      
        await prefs.setString('user_name', user['name']); 
        await prefs.setString('user_role', role); 

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selamat Datang, ${user['name']}!"), backgroundColor: pastelGreen),
        );
        
        // 3. NAVIGASI BERDASARKAN ROLE
        if (role == 'admin') {
          print("[$role] NAVIGATE: To Admin Dashboard"); 
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomePage(
                userId: user['id'],
                userName: user['name'],
              ),
            ),
          );
        } else {
          print("[$role] NAVIGATE: To Client Main Page"); 
          Navigator.pushReplacement(
             context, 
             MaterialPageRoute(
               builder: (context) => MainPage(
                 userId: user['id'], 
                 role: user['role'], 
                 userName: user['name']
               )
             )
          );
        }
        
      } else {
        // Login Gagal
        print("[AUTH] LOGIN FAILED: ${data['message']}"); 
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: pastelPink),
        );
      }
    } catch (e) {
      // Error Koneksi
      print("[AUTH] LOGIN CONNECTION ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal koneksi ke server: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
      print("[AUTH] LOGIN PROCESS ENDED");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralWhite,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Aplikasi
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: pastelBlue.withOpacity(0.2),
                  shape: BoxShape.circle
                ),
                child: const Icon(Icons.pets, size: 80, color: pastelBlue),
              ),
              const SizedBox(height: 20),
              
              Text("PAWMATE", style: Theme.of(context).textTheme.displaySmall?.copyWith(color: pastelBlue, fontWeight: FontWeight.bold)),
              const Text("Teman Belanja Hewan Kesayanganmu", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              // Form Input
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined, color: pastelBlue)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline, color: pastelBlue)),
              ),
              const SizedBox(height: 24),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("MASUK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
              ),

              const SizedBox(height: 16),
              
              // Link Register
              TextButton(
                onPressed: () {
                  print("[AUTH] NAVIGATE: To Register Page"); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                },
                child: const Text("Belum punya akun? Daftar disini", style: TextStyle(color: pastelOrange)),
              )
            ],
          ),
        ),
      ),
    );
  }
}