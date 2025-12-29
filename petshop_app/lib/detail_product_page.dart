import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'theme.dart'; 

class DetailProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const DetailProductPage({super.key, required this.product});

  @override
  State<DetailProductPage> createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    print("[CLIENT] VIEWING DETAIL: ${widget.product['name']}");
  }

  // --- LOGIC +/- KUANTITAS ---
  void _increaseQuantity() {
    int maxStock = int.parse(widget.product['stock'].toString());
    
    if (_quantity < maxStock) {
      setState(() {
        _quantity++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ups, stok maksimal tercapai!"),
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  // --- LOGIC KIRIM KE DATABASE ---
  Future<void> _addToCart() async {
    // 1. Ambil ID User dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id'); 

    // Validasi: Kalau user belum login atau sesi habis
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sesi habis. Silakan login ulang."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return; 
    }

    // 2. Tampilkan Loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final url = Uri.parse('http://127.0.0.1:5000/cart'); 
      
      print("[CLIENT] SENDING TO SERVER... UserID: $userId");
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId, 
          'product_id': widget.product['id'],
          'quantity': _quantity,
        }),
      );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        print("[CLIENT] SUCCESS: Added to cart db");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Berhasil! $_quantity x ${widget.product['name']} masuk keranjang 🛒"),
              backgroundColor: pastelGreen,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context); 
        }
      } else {
        throw Exception('Server Error: ${response.body}');
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      
      print("[CLIENT] ERROR ADD CART: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal koneksi: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int maxStock = int.parse(widget.product['stock'].toString());
    double price = double.parse(widget.product['price'].toString());
    double totalPrice = price * _quantity;

    return Scaffold(
      backgroundColor: neutralWhite,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. GAMBAR PRODUK
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Image.asset(
                      widget.product['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                      ),
                    ),
                  ),

                  // 2. CONTAINER INFO
                  Container(
                    transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: neutralWhite,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product['name'],
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Rp ${price.toStringAsFixed(0)}", 
                              style: const TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold, 
                                color: pastelOrange
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: pastelBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Text(
                                "Stok Tersedia: $maxStock",
                                style: const TextStyle(color: pastelBlue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),

                        const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          widget.product['description'] ?? "Tidak ada deskripsi.",
                          style: const TextStyle(color: Colors.grey, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. BAGIAN BAWAH: SELECTOR QTY & TOMBOL BELI
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4))
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row Quantity Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQtyButton(Icons.remove, _decreaseQuantity, _quantity > 1),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "$_quantity",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildQtyButton(Icons.add, _increaseQuantity, _quantity < maxStock),
                  ],
                ),
                const SizedBox(height: 20),

                // Tombol Add to Cart
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pastelBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          // Menampilkan total harga hasil perkalian
                          "Tambah - Rp ${totalPrice.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap, bool isActive) {
    return InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? pastelBlue.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? pastelBlue : Colors.grey[300]!)
        ),
        child: Icon(icon, color: isActive ? pastelBlue : Colors.grey),
      ),
    );
  }
}