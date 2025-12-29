import 'package:flutter/material.dart';
import 'theme.dart';
import 'cart_page.dart';
import 'home_page.dart';
import 'shop_page.dart';
import 'profile_page.dart'; 

class MainPage extends StatefulWidget {
  final int userId;
  final String userName;
  final String role;

  const MainPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.role,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(userId: widget.userId, userName: widget.userName, role: widget.role),
      const ShopPage(),
      CartPage(userId: widget.userId, userName: widget.userName, role: widget.role),

      ProfilePage(
        userId: widget.userId, 
        userName: widget.userName, 
        role: widget.role
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralWhite,

      appBar: _currentIndex == 3 
          ? null 
          : AppBar(
              backgroundColor: pastelBlue,
              title: const Text(
                "Pawmate",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
            
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: pastelBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}