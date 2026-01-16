import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final String apiUrl = "http://192.168.101.12:5000"; 
  
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print("[ADMIN] INIT: Opening Product Management Page");
    _fetchProducts();
  }

// --- HELPER UNTUK MENAMPILKAN GAMBAR (SOLUSI UTAMA) ---
  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    // Jika image_url berisi path lokal/assets (tidak diawali http)
    if (!imageUrl.startsWith('http')) {
      return Image.asset(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Jika image_url adalah link internet
    return Image.network(
      imageUrl,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      // Menangani jika link mati atau 404
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      // Menangani loading saat gambar didownload
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 60,
          height: 60,
          color: Colors.grey[100],
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  // --- 1. FETCH PRODUCTS ---
  Future<void> _fetchProducts() async {
    print("[ADMIN] FETCH: Requesting product list...");
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(Uri.parse('$apiUrl/products')); 
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _products = data['data'];
          _isLoading = false;
        });
        print("[ADMIN] FETCH SUCCESS: Found ${_products.length} products.");
      } else {
        print("[ADMIN] FETCH ERROR: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("[ADMIN] FETCH EXCEPTION: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- 2. ADD PRODUCT ---
  Future<void> _addProduct(Map<String, dynamic> productData) async {
    print("[ADMIN] ADD REQUEST: Adding product '${productData['name']}'");
    
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/admin/products'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201) {
        print("[ADMIN] ADD SUCCESS: Product created.");
        if (!mounted) return;
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil ditambahkan!"), backgroundColor: Colors.green),
        );
        _fetchProducts(); 
      } else {
        print("[ADMIN] ADD FAILED: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menambah produk"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("[ADMIN] ADD EXCEPTION: $e");
    }
  }

  // --- 3. EDIT PRODUCT ---
  Future<void> _editProduct(int id, Map<String, dynamic> productData) async {
    print("[ADMIN] EDIT REQUEST: Updating product ID $id");

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/admin/products/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200) {
        print("[ADMIN] EDIT SUCCESS: Product updated.");
        if (!mounted) return;
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil diperbarui!"), backgroundColor: Colors.blue),
        );
        _fetchProducts(); 
      } else {
        print("[ADMIN] EDIT FAILED: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal update: ${response.body}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("[ADMIN] EDIT EXCEPTION: $e");
    }
  }

  // --- 4. DELETE PRODUCT ---
  Future<void> _deleteProduct(int id) async {
    print("[ADMIN] DELETE REQUEST: Deleting product ID $id");
    
    try {
      final response = await http.delete(Uri.parse('$apiUrl/admin/products/$id'));

      if (response.statusCode == 200) {
        print("[ADMIN] DELETE SUCCESS: Product ID $id removed.");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil dihapus!"), backgroundColor: Colors.green),
        );
        _fetchProducts(); 
      } else {
        print("[ADMIN] DELETE FAILED: ${response.body}");
      }
    } catch (e) {
      print("[ADMIN] DELETE EXCEPTION: $e");
    }
  }

  void _showProductForm({Map<String, dynamic>? product}) {
    final bool isEditMode = product != null;

    final TextEditingController nameController = TextEditingController(text: isEditMode ? product['name'] : '');
    final TextEditingController descController = TextEditingController(text: isEditMode ? product['description'] : '');
    final TextEditingController priceController = TextEditingController(text: isEditMode ? product['price'].toString() : '');
    final TextEditingController stockController = TextEditingController(text: isEditMode ? product['stock'].toString() : '');
    final TextEditingController imageController = TextEditingController(text: isEditMode ? product['image_url'] : '');
    
    String selectedCategory = isEditMode ? product['category'] : 'Makanan'; 
    const List<String> categories = ['Makanan', 'Aksesoris', 'Mainan', 'Obat'];
    if (!categories.contains(selectedCategory)) {
      selectedCategory = 'Makanan';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditMode ? "Edit Produk" : "Tambah Produk Baru"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Nama Produk", icon: Icon(Icons.abc)),
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: "Deskripsi Singkat", icon: Icon(Icons.description)),
                    ),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Harga (Rp)", icon: Icon(Icons.attach_money)),
                    ),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Stok", icon: Icon(Icons.inventory)),
                    ),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: "URL Gambar", 
                        icon: Icon(Icons.image),
                        hintText: "http://..."
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: "Kategori", icon: Icon(Icons.category)),
                      items: categories
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEditMode ? Colors.orange : pastelBlue
                  ),
                  onPressed: () {
                    if (nameController.text.isEmpty || priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nama dan Harga wajib diisi!")),
                      );
                      return;
                    }

                    Map<String, dynamic> formData = {
                      "name": nameController.text,
                      "description": descController.text,
                      "price": int.tryParse(priceController.text) ?? 0,
                      "stock": int.tryParse(stockController.text) ?? 0,
                      "category": selectedCategory,
                      "image_url": imageController.text.isEmpty 
                          ? "https://via.placeholder.com/150"
                          : imageController.text
                    };

                    if (isEditMode) {
                      _editProduct(product['id'], formData);
                    } else {
                      _addProduct(formData);
                    }
                  },
                  child: Text(isEditMode ? "Update" : "Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirm(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: Text("Apakah Anda yakin ingin menghapus '$name'?\nTindakan ini tidak bisa dibatalkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(id);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralWhite,
      appBar: AppBar(
        title: const Text("Kelola Produk", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: pastelBlue,
        onPressed: () => _showProductForm(), 
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text("Belum ada produk."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildProductImage(product['image_url']),
                        ),
                        title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Rp ${product['price']}"),
                            Text("Stok: ${product['stock']}", style: TextStyle(color: (product['stock'] < 5) ? Colors.red : Colors.grey)),
                          ],
                        ),
                        // TOMBOL EDIT & HAPUS
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showProductForm(product: product), 
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _showDeleteConfirm(product['id'], product['name']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}