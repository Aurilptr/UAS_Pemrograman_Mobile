import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'theme.dart';

// --- KONFIGURASI API PUBLIK ---
const String publicApiUrl = 'https://catfact.ninja/fact';

class HomePage extends StatefulWidget {
  final int userId;
  final String userName;
  final String role;

  const HomePage({
    super.key, 
    required this.userId, 
    required this.userName, 
    required this.role
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _catFact = "Memuat fakta unik...";
  bool _isFactLoading = true;

  final PageController _pageController = PageController();
  int _currentBannerPage = 0;
  Timer? _bannerTimer;
  final List<String> _bannerImages = [
    "assets/images/banner1.png",
    "assets/images/banner2.png",
    "assets/images/banner3.png",
  ];

  @override
  void initState() {
    super.initState();
    _fetchCatFact();

    // Timer Auto Slide (5 Detik)
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentBannerPage < _bannerImages.length - 1) {
        _currentBannerPage++;
      } else {
        _currentBannerPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // --- FUNGSI FETCH DATA DENGAN LOGGING ---
  Future<void> _fetchCatFact() async {
    // Log Mulai
    print("🚀 [PUBLIC API] Memulai request ke: $publicApiUrl");

    try {
      final response = await http.get(Uri.parse(publicApiUrl));
      
      // Log Status Code
      print("📡 [PUBLIC API] Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Log Data Masuk
        print("✅ [PUBLIC API] Data berhasil diambil: ${data['fact']}");

        if (mounted) {
          setState(() {
            _catFact = data['fact'];
            _isFactLoading = false;
          });
        }
      } else {
        // Log Gagal Server
        print("❌ [PUBLIC API] Gagal mengambil data. Server merespon: ${response.body}");
        if (mounted) {
            setState(() {
                _catFact = "Server sedang sibuk.";
                _isFactLoading = false;
            });
        }
      }
    } catch (e) {
      // Log Error Koneksi
      print("⚠️ [PUBLIC API] Terjadi Error Exception: $e");
      
      if (mounted) {
        setState(() {
          _catFact = "Gagal memuat fakta hewan. Periksa internet.";
          _isFactLoading = false;
        });
      }
    }
  }

  // --- UI DASHBOARD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, ${widget.userName}! 👋",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: pastelBlue,
              ),
            ),
            const Text("Yuk temukan kebutuhan anabulmu.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Banner Slider
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _bannerImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildAssetBanner(_bannerImages[index]);
                },
              ),
            ),
            
            // Indikator Titik Slider
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bannerImages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBannerPage == index ? pastelBlue : Colors.grey[300],
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Card Fakta Unik
            Text("Fakta Hari Ini 🐱", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: pastelYellow, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text("Tahukah Kamu?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Content Fakta
                  _isFactLoading
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(),
                        ))
                      : Text(
                          "\"$_catFact\"",
                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                  
                  const SizedBox(height: 8),
                  
                  // Tombol Refresh Fakta
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                            _isFactLoading = true;
                        });
                        _fetchCatFact();
                      },
                      child: const Text("Fakta Lain", style: TextStyle(color: pastelBlue)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetBanner(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: Colors.grey[300], child: const Icon(Icons.broken_image));
          },
        ),
      ),
    );
  }
}