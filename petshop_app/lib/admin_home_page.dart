import 'package:flutter/material.dart';
import 'login_page.dart';
import 'theme.dart'; 
import 'admin_orders_page.dart';
import 'admin_products_page.dart';
import 'admin_users_page.dart';
import 'admin_report_page.dart';

class AdminHomePage extends StatefulWidget {
  final int userId;
  final String userName;

  const AdminHomePage({super.key, required this.userId, required this.userName});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralWhite,
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WELCOME BANNER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: pastelBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, color: pastelBlue),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Halo, Admin ${widget.userName}", 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const Text("Selamat bekerja!", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text("Menu Utama", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // GRID MENU ADMIN
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // 1. MANAJEMEN PESANAN
                _buildAdminMenuCard(
                  icon: Icons.shopping_bag_outlined,
                  title: "Pesanan Masuk",
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminOrdersPage()),
                    );
                  },
                ),

                /// 2. MANAJEMEN PRODUK
                _buildAdminMenuCard(
                  icon: Icons.inventory_2_outlined,
                  title: "Kelola Produk",
                  color: Colors.blue,
                  onTap: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const AdminProductsPage()),
                     );
                  },
                ),

                // 3. LAPORAN BISNIS
                _buildAdminMenuCard(
                  icon: Icons.bar_chart,
                  title: "Laporan Bisnis",
                  color: Colors.purple,
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminReportPage()),
                    );
                  },
                ),

                // 4. USERS 
                _buildAdminMenuCard(
                  icon: Icons.people_outline,
                  title: "Daftar User",
                  color: Colors.teal,
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminUsersPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuCard({
    required IconData icon, 
    required String title, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}