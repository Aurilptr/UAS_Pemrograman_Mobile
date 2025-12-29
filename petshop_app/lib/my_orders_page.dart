import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyOrdersPage extends StatefulWidget {
  final int userId;

  const MyOrdersPage({super.key, required this.userId});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // 1. AMBIL DATA PESANAN
  Future<void> _fetchOrders() async {
    final url = Uri.parse('http://127.0.0.1:5000/my_orders/${widget.userId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _orders = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error koneksi: $e");
      setState(() => _isLoading = false);
    }
  }

  // 2. FUNGSI MEMBATALKAN PESANAN
  Future<void> _cancelOrder(int orderId, String reason) async {
    final url = Uri.parse('http://127.0.0.1:5000/orders/cancel');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': orderId,
          'reason': reason, 
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
          );
        }
        _fetchOrders(); 
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membatalkan: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 3. DIALOG PILIH ALASAN
  void _showCancelDialog(int orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Pilih Alasan Pembatalan"),
          children: [
            _buildReasonOption(orderId, "Salah pilih produk"),
            _buildReasonOption(orderId, "Ingin ubah alamat pengiriman"),
            _buildReasonOption(orderId, "Menemukan harga lebih murah"),
            _buildReasonOption(orderId, "Lupa memasukkan voucher"),
            _buildReasonOption(orderId, "Lainnya"),
          ],
        );
      },
    );
  }

  Widget _buildReasonOption(int orderId, String reason) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context);
        _cancelOrder(orderId, reason);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(reason, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending_payment': return Colors.orange;
      case 'waiting_confirmation': return Colors.blue;
      case 'shipped': return Colors.purple; 
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: const Text("Riwayat Pesanan", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text("Belum ada pesanan"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final items = order['items'] as List;
                    
                    // Logic Cek Status
                    bool canCancel = order['status'] == 'pending_payment';
                    bool isCancelled = order['status'] == 'cancelled';
                   
                    String reasonText = order['cancel_reason'] ?? '-';
                    bool cancelledByAdmin = reasonText.toLowerCase().contains('admin');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- HEADER: ID & STATUS ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Order #${order['id']}", 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order['status']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  order['status'].toString().replaceAll('_', ' ').toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(order['status']),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          // --- LIST BARANG ---
                          ...items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['image'] ?? 'https://via.placeholder.com/60',
                                      width: 60, height: 60, fit: BoxFit.cover,
                                      errorBuilder: (c, o, s) => Container(
                                        width: 60, height: 60, color: Colors.grey[200], 
                                        child: const Icon(Icons.image_not_supported, size: 20)
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'],
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text("${item['quantity']} barang", 
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          const Divider(height: 20),

                          // --- FOOTER: TOTAL & ACTION ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total Belanja", style: TextStyle(fontSize: 12)),
                                  Text(
                                    "Rp ${order['total_price']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.orange, 
                                      fontSize: 16
                                    ),
                                  ),
                                ],
                              ),
                              
                              // TOMBOL BATALKAN
                              if (canCancel)
                                ElevatedButton(
                                  onPressed: () => _showCancelDialog(order['id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[50],
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(color: Colors.red)
                                    )
                                  ),
                                  child: const Text("Batalkan", 
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                )
                            ],
                          ),

                          // --- SECTION KHUSUS ALASAN PEMBATALAN ---
                          if (isCancelled) ...[
                             const SizedBox(height: 16),
                             Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.grey[100],
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.grey[300]!)
                               ),
                               child: Row(
                                 children: [
                                   Icon(
                                     cancelledByAdmin ? Icons.admin_panel_settings : Icons.person,
                                     size: 20,
                                     color: Colors.grey[600],
                                   ),
                                   const SizedBox(width: 8),
                                   Expanded(
                                     child: RichText(
                                       text: TextSpan(
                                         style: TextStyle(color: Colors.grey[800], fontSize: 12),
                                         children: [
                                           TextSpan(
                                             text: cancelledByAdmin ? "Dibatalkan Admin: " : "Dibatalkan Pembeli: ",
                                             style: const TextStyle(fontWeight: FontWeight.bold)
                                           ),
                                           TextSpan(
                                             text: reasonText.replaceAll('[Admin]', '').trim(), 
                                           ),
                                         ],
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             )
                          ]
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}