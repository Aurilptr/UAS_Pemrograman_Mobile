import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print("[ADMIN] INIT: Opening Orders Page");
    _tabController = TabController(length: 5, vsync: this);
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    print("[ADMIN] FETCHING: Getting order list from server...");
    final url = Uri.parse('http://192.168.101.12:5000/admin/orders'); 
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _allOrders = data['data'];
          _isLoading = false;
        });
        print("[ADMIN] FETCH SUCCESS: Found ${_allOrders.length} orders.");
      } else {
        print("[ADMIN] FETCH ERROR: Server returned ${response.statusCode}");
      }
    } catch (e) {
      print("[ADMIN] FETCH EXCEPTION: $e");
      setState(() => _isLoading = false);
    }
  }

  // Fungsi Update Status
  Future<void> _updateStatus(int orderId, String newStatus, {String? reason}) async {
    print("[ADMIN] UPDATE REQUEST: Order $orderId -> $newStatus (Reason: $reason)");
    
    final url = Uri.parse('http://192.168.101.12:5000/admin/order_status');
    try {
      final Map<String, dynamic> bodyData = {
        'order_id': orderId,
        'status': newStatus,
      };

      if (reason != null) {
        bodyData['cancel_reason'] = reason;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        print("[ADMIN] UPDATE SUCCESS: Status changed to $newStatus");
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == 'cancelled' ? "Pesanan dibatalkan." : "Status berhasil diperbarui!"),
            backgroundColor: newStatus == 'cancelled' ? Colors.red : Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        _fetchOrders(); 
      } else {
        print("[ADMIN] UPDATE FAILED: ${response.body}");
      }
    } catch (e) {
      print("[ADMIN] UPDATE EXCEPTION: $e");
    }
  }

  void _showCancelDialog(int orderId) {
    print("[ADMIN] DIALOG: Opening Cancel Dialog for Order $orderId");
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Batalkan Pesanan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Apakah Anda yakin ingin membatalkan pesanan ini?"),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: "Alasan Pembatalan (Wajib)",
                  hintText: "Contoh: Stok habis, Alamat tidak terjangkau",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("[ADMIN] DIALOG: Cancelled by user");
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mohon isi alasan pembatalan")),
                  );
                  return;
                }
                
                Navigator.pop(context); 
                
                String finalReason = "[Admin] ${reasonController.text}";
                print("[ADMIN] ACTION: Confirm Cancel Order $orderId. Reason: $finalReason");
                
                _updateStatus(orderId, 'cancelled', reason: finalReason);
              },
              child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  List<dynamic> _getOrdersByFilter(List<String> statuses) {
    return _allOrders.where((order) => statuses.contains(order['status'])).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending_payment': return Colors.orange;
      case 'waiting_confirmation': return Colors.amber[700]!;
      case 'paid': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralWhite,
      appBar: AppBar(
        title: const Text("Manajemen Pesanan", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: pastelBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: pastelBlue,
          isScrollable: true,
          onTap: (index) {
            print("[ADMIN] TAB CHANGED: Index $index");
          },
          tabs: const [
            Tab(text: "Perlu Konfirmasi"),
            Tab(text: "Siap Kirim"), 
            Tab(text: "Sedang Dikirim"), 
            Tab(text: "Selesai"),
            Tab(text: "Dibatalkan"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_getOrdersByFilter(['waiting_confirmation', 'pending_payment']), actionType: 'confirm'),
                _buildOrderList(_getOrdersByFilter(['paid']), actionType: 'ship'),
                _buildOrderList(_getOrdersByFilter(['shipped']), actionType: 'shipped_view'),
                _buildOrderList(_getOrdersByFilter(['completed']), actionType: 'none'),
                _buildOrderList(_getOrdersByFilter(['cancelled']), actionType: 'none'),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, {required String actionType}) {
    if (orders.isEmpty) {
      return const Center(child: Text("Tidak ada pesanan di kategori ini.", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final String imageUrl = order['product_image'] ?? 'assets/images/placeholder.jpeg';

        // --- LOGIKA DETEKSI SIAPA YANG CANCEL ---
        bool cancelledByAdmin = false;
        String displayReason = "";
        if (order['status'] == 'cancelled') {
           String rawReason = order['cancel_reason'] ?? "-";
           if (rawReason.contains("[Admin]")) {
             cancelledByAdmin = true;
             displayReason = rawReason.replaceAll("[Admin]", "").trim();
           } else {
             displayReason = rawReason;
           }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER KARTU ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        imageUrl,
                        width: 80, height: 80, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                            print("Error loading image: $error"); // Ini akan memberitahu kenapa gagal
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Order #${order['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(order['created_at'].toString().substring(0, 10), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("Pembeli: ${order['buyer_name']}", style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text("Total: Rp ${order['total_price']}", style: const TextStyle(fontWeight: FontWeight.bold, color: pastelOrange, fontSize: 16)),
                          const SizedBox(height: 6),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _getStatusColor(order['status']).withOpacity(0.5))
                            ),
                            child: Text(
                              order['status'].toString().toUpperCase().replaceAll('_', ' '),
                              style: TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.bold, 
                                color: _getStatusColor(order['status'])
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // --- INFO PEMBATALAN  ---
                if (order['status'] == 'cancelled') ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    children: [
                      Icon(
                        cancelledByAdmin ? Icons.admin_panel_settings : Icons.person,
                        size: 16,
                        color: cancelledByAdmin ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: cancelledByAdmin ? "Dibatalkan Admin: " : "Dibatalkan Pembeli: ", 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                              ),
                              TextSpan(
                                text: displayReason, 
                                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                
                // --- ACTION BUTTONS ---
                
                // 1. Tab Konfirmasi
                if (actionType == 'confirm')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showCancelDialog(order['id']),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Tolak"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print("[ADMIN] CLICK: Confirm Payment Order #${order['id']}");
                            _updateStatus(order['id'], 'paid');
                          },
                          icon: const Icon(Icons.check_circle, size: 18, color: Colors.white),
                          label: const Text("Terima", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                    ],
                  )
                
                // 2. Tab Siap Kirim
                else if (actionType == 'ship')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showCancelDialog(order['id']),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Batal"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print("[ADMIN] CLICK: Ship Order #${order['id']}");
                            _updateStatus(order['id'], 'shipped');
                          },
                          icon: const Icon(Icons.local_shipping, size: 18, color: Colors.white),
                          label: const Text("Kirim Barang", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                    ],
                  )

                // 3. Tab Sedang Dikirim
                else if (actionType == 'shipped_view')
                   SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        print("[ADMIN] CLICK: Force Complete Order #${order['id']}");
                        _updateStatus(order['id'], 'completed');
                      },
                      icon: const Icon(Icons.check, size: 18, color: Colors.green),
                      label: const Text("Tandai Selesai", style: TextStyle(color: Colors.green)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green)),
                    ),
                  ),

              ],
            ),
          ),
        );
      },
    );
  }
}