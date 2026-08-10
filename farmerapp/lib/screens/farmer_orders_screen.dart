import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() =>
      _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState
    extends State<FarmerOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // ============================================================
  // LOAD ORDERS
  // ============================================================

  Future<void> _loadOrders() async {
    try {
      final token =
          context.read<AuthProvider>().token;

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          _loading = false;
        });

        return;
      }

      final orders =
          await ApiService.getFarmerOrders(token);

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'Farmer orders error: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load orders: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // UPDATE ORDER STATUS
  // ============================================================

  Future<void> _updateStatus(
    String orderId,
    String status,
  ) async {
    try {
      final token =
          context.read<AuthProvider>().token;

      if (token == null || token.isEmpty) {
        return;
      }

      await ApiService.updateOrderStatus(
        token: token,
        orderId: orderId,
        status: status,
      );

      await _loadOrders();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order updated to $status',
          ),
          backgroundColor:
              const Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update order: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Farmer Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor:
          const Color(0xFFF7F9F5),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _orders.isEmpty
                ? ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 220),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons
                                  .shopping_bag_outlined,
                              size: 65,
                              color:
                                  Colors.grey,
                            ),
                            SizedBox(height: 15),
                            Text(
                              'No orders yet.',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Buyer orders will appear here.',
                              style: TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder:
                        (context, index) {
                      final order =
                          _orders[index];

                      final String orderId =
                          order['_id']
                                  ?.toString() ??
                              '';

                      final String status =
                          order['orderStatus']
                                  ?.toString() ??
                              'placed';

                      final dynamic rawItems =
                          order['items'];

                      final List items =
                          rawItems is List
                              ? rawItems
                              : [];

                      final dynamic total =
                          order['totalAmount'] ??
                              0;

                      return _buildOrderCard(
                        order: order,
                        orderId: orderId,
                        status: status,
                        items: items,
                        total: total,
                      );
                    },
                  ),
      ),
    );
  }

  // ============================================================
  // ORDER CARD
  // ============================================================

  Widget _buildOrderCard({
    required Map<String, dynamic> order,
    required String orderId,
    required String status,
    required List items,
    required dynamic total,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 16),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.05),
            blurRadius: 8,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ======================================================
          // ORDER HEADER
          // ======================================================

          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #$orderId',
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ),
              _statusChip(status),
            ],
          ),

          const SizedBox(height: 15),

          // ======================================================
          // ITEMS
          // ======================================================

          if (items.isEmpty)
            const Text(
              'No items',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

          ...items.map(
            (item) {
              if (item is! Map) {
                return const SizedBox();
              }

              final Map<String, dynamic>
                  itemMap =
                  Map<String, dynamic>.from(
                item,
              );

              final String name =
                  itemMap['cropName']
                          ?.toString() ??
                      'Crop';

              final dynamic quantity =
                  itemMap['quantity'] ?? 0;

              final dynamic subtotal =
                  itemMap['subtotal'] ?? 0;

              final String unit =
                  itemMap['unit']
                          ?.toString() ??
                      'kg';

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 8,
                ),
                padding:
                    const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF7F9F5),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.eco_outlined,
                      color:
                          Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            name,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            '$quantity $unit',
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '₹$subtotal',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 25),

          // ======================================================
          // TOTAL
          // ======================================================

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '₹$total',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF2E7D32),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ======================================================
          // PAYMENT
          // ======================================================

          Row(
            children: [
              const Icon(
                Icons
                    .payment_outlined,
                size: 20,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment: ${order['paymentMethod'] ?? 'COD'}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ======================================================
          // STATUS DROPDOWN
          // ======================================================

          if (status != 'delivered' &&
              status != 'cancelled')
            DropdownButtonFormField<
                String>(
              initialValue:
                  _validStatus(status),
              decoration:
                  InputDecoration(
                labelText:
                    'Update order status',
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'placed',
                  child:
                      Text('Placed'),
                ),
                DropdownMenuItem(
                  value: 'confirmed',
                  child:
                      Text('Confirmed'),
                ),
                DropdownMenuItem(
                  value: 'processing',
                  child:
                      Text('Processing'),
                ),
                DropdownMenuItem(
                  value: 'shipped',
                  child:
                      Text('Shipped'),
                ),
                DropdownMenuItem(
                  value: 'delivered',
                  child:
                      Text('Delivered'),
                ),
                DropdownMenuItem(
                  value: 'cancelled',
                  child:
                      Text('Cancelled'),
                ),
              ],
              onChanged: (value) {
                if (value == null ||
                    value == status) {
                  return;
                }

                _updateStatus(
                  orderId,
                  value,
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // VALID STATUS
  // ============================================================

  String _validStatus(
    String status,
  ) {
    const statuses = [
      'placed',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
    ];

    return statuses.contains(status)
        ? status
        : 'placed';
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(
    String status,
  ) {
    Color backgroundColor;

    switch (status) {
      case 'delivered':
        backgroundColor =
            Colors.green.shade100;
        break;

      case 'cancelled':
        backgroundColor =
            Colors.red.shade100;
        break;

      case 'shipped':
        backgroundColor =
            Colors.blue.shade100;
        break;

      case 'processing':
        backgroundColor =
            Colors.orange.shade100;
        break;

      case 'confirmed':
        backgroundColor =
            Colors.teal.shade100;
        break;

      default:
        backgroundColor =
            Colors.grey.shade200;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }
}