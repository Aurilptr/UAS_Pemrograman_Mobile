import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';
import 'payment_page.dart';

const String baseUrl = 'http://192.168.101.12:5000'; 

class CartPage extends StatefulWidget {
  final int userId;
  final String userName;
  final String role;

  const CartPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.role,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  // --- AMBIL DATA CART ---
  Future<void> _fetchCartItems() async {
    try {
      final url = Uri.parse('$baseUrl/cart/${widget.userId}'); 
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> fetchedItems = data['data'];

        for (var item in fetchedItems) {
          item['isSelected'] = false;
          item['stock'] = item['stock'] ?? 0; 
        }

        if (mounted) {
          setState(() {
            _cartItems = fetchedItems;
            _isLoading = false;
          });
          _calculateTotal();
        }
      } else {
        throw Exception("Gagal ambil data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error Fetch Cart: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- HAPUS ITEM ---
  Future<void> _deleteCartItem(int index) async {
    final deletedItem = _cartItems[index];
    final cartId = deletedItem['id']; 

    // 1. Optimistic Update: Hapus visual dulu biar UI terasa cepat
    setState(() {
      _cartItems.removeAt(index);
      _calculateTotal();
    });

    try {
       final url = Uri.parse('$baseUrl/cart/delete/$cartId'); 
       
       final response = await http.delete(url);

       if (response.statusCode == 200) {
         print("✅ Item $cartId berhasil dihapus di server");
       } else {
         throw Exception("Gagal hapus, status: ${response.statusCode}");
       }

    } catch (e) {
      print("❌ Gagal hapus di server: $e");
      
      // 2. Rollback: Kembalikan item ke list jika gagal (Server Error/Internet Mati)
      if (mounted) {
        setState(() {
          _cartItems.insert(index, deletedItem);
          _calculateTotal();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus item: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _calculateTotal() {
    double tempTotal = 0;
    for (var item in _cartItems) {
      if (item['isSelected'] == true) { 
        double price = double.tryParse(item['price'].toString()) ?? 0;
        int qty = int.tryParse(item['quantity'].toString()) ?? 0;
        tempTotal += (price * qty);
      }
    }
    setState(() {
      _totalPrice = tempTotal;
    });
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      int currentQty = int.parse(_cartItems[index]['quantity'].toString());
      int stock = int.parse(_cartItems[index]['stock'].toString());
      int newQty = currentQty + change;

      if (newQty >= 1 && newQty <= stock) {
        _cartItems[index]['quantity'] = newQty;
        _calculateTotal(); 
      }
    });
  }

  void _toggleSelection(int index, bool? value) {
    setState(() {
      _cartItems[index]['isSelected'] = value ?? false;
      _calculateTotal();
    });
  }

  void _onCheckout() {
    List selectedItems = _cartItems.where((item) => item['isSelected'] == true).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          selectedItems: selectedItems, 
          totalPrice: _totalPrice,
          userId: widget.userId,
          userName: widget.userName,
          role: widget.role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralWhite,
      appBar: AppBar(
        title: const Text("Keranjang Saya", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? const Center(child: Text("Keranjang masih kosong 🛒"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    return _buildCartItem(index);
                  },
                ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4))]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Pembayaran:", style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text(
                  "Rp ${_totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: pastelOrange),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _totalPrice == 0 ? null : _onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelBlue,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Checkout Sekarang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _cartItems[index];
    int qty = int.tryParse(item['quantity'].toString()) ?? 1;
    double price = double.tryParse(item['price'].toString()) ?? 0;
    int stock = int.tryParse(item['stock'].toString()) ?? 0;
    bool isSelected = item['isSelected'] ?? false;
    
    bool isMinLimit = qty <= 1;
    bool isMaxLimit = qty >= stock;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? pastelBlue : Colors.grey[200]!, width: isSelected ? 1.5 : 1)
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isSelected,
              activeColor: pastelBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (val) => _toggleSelection(index, val),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 70, height: 70,
              child: Image.asset( 
                item['image_url'] ?? 'petshop_app/assets/images/placeholder.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? 'Item', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Stok: $stock", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("Rp ${price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: pastelOrange)),
                    
                    const Spacer(), 

                    // --- QUANTITY CONTROL ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Row(
                        children: [
                          _buildQtyButton(
                            icon: Icons.remove, 
                            isDisabled: isMinLimit, 
                            onTap: () => _updateQuantity(index, -1)
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          _buildQtyButton(
                            icon: Icons.add, 
                            isDisabled: isMaxLimit, 
                            onTap: () => _updateQuantity(index, 1)
                          ),
                        ],
                      ),
                    ),

                    // --- TOMBOL DELETE ---
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                         showDialog(
                           context: context, 
                           builder: (ctx) => AlertDialog(
                             title: const Text("Hapus Item?"),
                             content: const Text("Apakah kamu yakin ingin menghapus barang ini dari keranjang?"),
                             actions: [
                               TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Batal")),
                               TextButton(
                                 onPressed: (){
                                   Navigator.pop(ctx);
                                   _deleteCartItem(index);
                                 }, 
                                 child: const Text("Hapus", style: TextStyle(color: Colors.red))
                               ),
                             ],
                           )
                         );
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({required IconData icon, required bool isDisabled, required VoidCallback onTap}) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon, 
          size: 16, 
          color: isDisabled ? Colors.grey[300] : Colors.black
        ),
      ),
    );
  }
}