import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';
import 'detail_product_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    print("[CLIENT] SHOP: Fetching product list from server...");

    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/products'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _products = data['data'];
          _isLoading = false;
        });

        print("[CLIENT] SHOP SUCCESS: Loaded ${_products.length} products.");
        for (var p in _products) {
           print("   -> Found: ${p['name']} (Stock: ${p['stock']})");
        }

      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print("[CLIENT] SHOP ERROR: $e");
      setState(() {
        _errorMessage = "Gagal mengambil data produk.\nCek koneksi server.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralWhite,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, textAlign: TextAlign.center))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    childAspectRatio: 0.70, 
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return _buildProductCard(product);
                  },
                ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    // 1. Ambil Data Stok & Cek Ketersediaan
    int stock = product['stock'];
    bool isAvailable = stock > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GAMBAR PRODUK 
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    product['image_url'],
                    width: double.infinity,
                    height: double.infinity, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                
                // 2. LOGIKA VISUAL: Jika Stok Habis, Gelapkan Gambar & Tulis "HABIS"
                if (!isAvailable)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6), 
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white, width: 2)
                        ),
                        child: const Text(
                          "HABIS",
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // INFO PRODUK
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 14,
                    color: isAvailable ? Colors.black : Colors.grey, 
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp ${product['price']}",
                      style: TextStyle(
                        color: isAvailable ? pastelOrange : Colors.grey, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    // 3. TAMPILKAN INFO STOK KECIL
                    Text(
                      "Sisa: $stock",
                      style: TextStyle(
                        fontSize: 10,
                        color: stock < 5 ? Colors.red : Colors.grey, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // TOMBOL DETAIL / HABIS
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    // 4. LOGIKA KLIK: Kalau !isAvailable, onPressed jadi null (disable)
                    onPressed: isAvailable ? () async {
                      print("[CLIENT] CLICKED PRODUCT: ${product['name']}");
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailProductPage(product: product),
                        ),
                      );
                    } : null, 
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pastelBlue,
                      disabledBackgroundColor: Colors.grey[300], 
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      isAvailable ? "Detail Produk" : "Habis", 
                      style: TextStyle(
                        fontSize: 12, 
                        color: isAvailable ? Colors.white : Colors.grey[600]
                      )
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}