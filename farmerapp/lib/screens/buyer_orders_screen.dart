import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/order.dart';

class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() =>
      _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // ============================================================
  // LOAD BUYER ORDERS
  // ============================================================

  Future<void> _loadOrders() async {
    try {
      final token = context.read<AuthProvider>().token;

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          _loading = false;
        });

        return;
      }

      final orders = await ApiService.getMyOrders(token);

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Buyer orders error: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load orders: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // CANCEL ORDER
  // ============================================================

  Future<void> _cancelOrder(String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cancel Order',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to cancel this order?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      final token = context.read<AuthProvider>().token;

      if (token == null || token.isEmpty) {
        return;
      }

      await ApiService.cancelOrder(
        token: token,
        orderId: orderId,
      );

      await _loadOrders();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Order cancelled successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to cancel order: $e',
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
      backgroundColor: const Color(0xFFF7F9F5),

      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: _loadOrders,

        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _orders.isEmpty
                ? _buildEmptyOrders()
                : ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];

                      return _buildOrderCard(order);
                    },
                  ),
      ),
    );
  }

  // ============================================================
  // EMPTY ORDERS
  // ============================================================

  Widget _buildEmptyOrders() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      children: const [
        SizedBox(height: 180),

        Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 75,
                color: Colors.grey,
              ),

              SizedBox(height: 18),

              Text(
                'No orders yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Your orders will appear here.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ORDER CARD
  // ============================================================

  Widget _buildOrderCard(OrderModel order) {
    final status = order.orderStatus;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                  'Order #${order.id}',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              _statusChip(status),
            ],
          ),

          const SizedBox(height: 16),

          // ======================================================
          // STATUS TIMELINE
          // ======================================================

          _buildStatusTimeline(status),

          const SizedBox(height: 18),

          const Divider(),

          const SizedBox(height: 12),

          // ======================================================
          // ITEMS
          // ======================================================

          const Text(
            'Order Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...order.items.map(
            (item) => _buildItem(item),
          ),

          const SizedBox(height: 12),

          const Divider(),

          const SizedBox(height: 12),

          // ======================================================
          // TOTAL
          // ======================================================

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(
                '₹${order.totalAmount.toStringAsFixed(0)}',

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF2E7D32),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ======================================================
          // PAYMENT METHOD
          // ======================================================

          Row(
            children: [
              const Icon(
                Icons.payment_outlined,
                size: 20,
                color: Colors.grey,
              ),

              const SizedBox(width: 8),

              Text(
                'Payment: ${_formatPaymentMethod(order.paymentMethod)}',

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ======================================================
          // PAYMENT STATUS
          // ======================================================

          Row(
            children: [
              const Icon(
                Icons
                    .account_balance_wallet_outlined,
                size: 20,
                color: Colors.grey,
              ),

              const SizedBox(width: 8),

              Text(
                'Payment Status: ${_formatStatus(order.paymentStatus)}',

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ======================================================
          // SHIPPING ADDRESS
          // ======================================================

          _buildShippingAddress(order),

          // ======================================================
          // CANCEL BUTTON
          // ======================================================

          if (_canCancel(status)) ...[
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,

              child: OutlinedButton.icon(
                onPressed: () {
                  _cancelOrder(order.id);
                },

                icon: const Icon(
                  Icons.cancel_outlined,
                ),

                label: const Text(
                  'Cancel Order',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,

                  side: const BorderSide(
                    color: Colors.red,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // ORDER ITEM
  // ============================================================

  Widget _buildItem(OrderItem item) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 8),

      padding:
          const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F5),

        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color:
                  const Color(0xFFE8F5E9),

              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.eco_outlined,
              color:
                  Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  item.cropName.isEmpty
                      ? 'Crop'
                      : item.cropName,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${item.quantity} ${item.unit}',

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₹${item.subtotal.toStringAsFixed(0)}',

            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SHIPPING ADDRESS
  // ============================================================

  Widget _buildShippingAddress(
    OrderModel order,
  ) {
    final parts = <String>[];

    if (order.address.trim().isNotEmpty) {
      parts.add(order.address.trim());
    }

    if (order.city.trim().isNotEmpty) {
      parts.add(order.city.trim());
    }

    if (order.state.trim().isNotEmpty) {
      parts.add(order.state.trim());
    }

    if (order.pincode.trim().isNotEmpty) {
      parts.add(order.pincode.trim());
    }

    if (parts.isEmpty) {
      return const SizedBox();
    }

    final addressText =
        parts.join(', ');

    return Container(
      padding:
          const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color:
            const Color(0xFFF7F9F5),

        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.location_on_outlined,
            color:
                Color(0xFF2E7D32),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Delivery Address',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  addressText,

                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'confirmed':
        backgroundColor =
            Colors.blue.withValues(
          alpha: 0.12,
        );
        textColor = Colors.blue;
        break;

      case 'processing':
        backgroundColor =
            Colors.orange.withValues(
          alpha: 0.12,
        );
        textColor =
            Colors.orange.shade800;
        break;

      case 'shipped':
        backgroundColor =
            Colors.indigo.withValues(
          alpha: 0.12,
        );
        textColor = Colors.indigo;
        break;

      case 'out_for_delivery':
        backgroundColor =
            Colors.purple.withValues(
          alpha: 0.12,
        );
        textColor = Colors.purple;
        break;

      case 'delivered':
        backgroundColor =
            Colors.green.withValues(
          alpha: 0.12,
        );
        textColor =
            Colors.green.shade700;
        break;

      case 'cancelled':
        backgroundColor =
            Colors.red.withValues(
          alpha: 0.12,
        );
        textColor = Colors.red;
        break;

      case 'rejected':
        backgroundColor =
            Colors.red.withValues(
          alpha: 0.12,
        );
        textColor = Colors.red;
        break;

      default:
        backgroundColor =
            Colors.amber.withValues(
          alpha: 0.15,
        );
        textColor =
            Colors.orange.shade800;
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
        _formatStatus(status),

        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS TIMELINE
  // ============================================================

  Widget _buildStatusTimeline(
    String status,
  ) {
    const statuses = [
      'placed',
      'confirmed',
      'processing',
      'shipped',
      'out_for_delivery',
      'delivered',
    ];

    final currentIndex =
        statuses.indexOf(status);

    if (status == 'cancelled' ||
        status == 'rejected') {
      return Container(
        padding:
            const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color:
              Colors.red.withValues(
            alpha: 0.07,
          ),

          borderRadius:
              BorderRadius.circular(12),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.cancel_outlined,
              color: Colors.red,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                _formatStatus(status),

                style: const TextStyle(
                  color: Colors.red,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _timelineItem(
          title: 'Order Placed',
          icon:
              Icons.shopping_bag_outlined,
          active: currentIndex >= 0,
          completed: currentIndex > 0,
          isLast: false,
        ),

        _timelineItem(
          title: 'Confirmed',
          icon:
              Icons.check_circle_outline,
          active: currentIndex >= 1,
          completed: currentIndex > 1,
          isLast: false,
        ),

        _timelineItem(
          title: 'Processing',
          icon:
              Icons.inventory_2_outlined,
          active: currentIndex >= 2,
          completed: currentIndex > 2,
          isLast: false,
        ),

        _timelineItem(
          title: 'Shipped',
          icon:
              Icons.local_shipping_outlined,
          active: currentIndex >= 3,
          completed: currentIndex > 3,
          isLast: false,
        ),

        _timelineItem(
          title: 'Out for Delivery',
          icon:
              Icons.delivery_dining_outlined,
          active: currentIndex >= 4,
          completed: currentIndex > 4,
          isLast: false,
        ),

        _timelineItem(
          title: 'Delivered',
          icon: Icons.home_outlined,
          active: currentIndex >= 5,
          completed: false,
          isLast: true,
        ),
      ],
    );
  }

  // ============================================================
  // TIMELINE ITEM
  // ============================================================

  Widget _timelineItem({
    required String title,
    required IconData icon,
    required bool active,
    required bool completed,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        SizedBox(
          width: 32,

          child: Column(
            children: [
              Icon(
                icon,
                size: 22,

                color: active
                    ? const Color(
                        0xFF2E7D32,
                      )
                    : Colors.grey.shade400,
              ),

              if (!isLast)
                Container(
                  width: 2,
                  height: 22,

                  color: completed
                      ? const Color(
                          0xFF2E7D32,
                        )
                      : Colors.grey.shade300,
                ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 2,
            ),

            child: Text(
              title,

              style: TextStyle(
                fontSize: 13,

                fontWeight: active
                    ? FontWeight.bold
                    : FontWeight.normal,

                color: active
                    ? Colors.black87
                    : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CAN CANCEL
  // ============================================================

  bool _canCancel(String status) {
    return status != 'shipped' &&
        status != 'out_for_delivery' &&
        status != 'delivered' &&
        status != 'cancelled' &&
        status != 'rejected';
  }

  // ============================================================
  // FORMAT STATUS
  // ============================================================

  String _formatStatus(String status) {
    switch (status) {
      case 'placed':
        return 'Placed';

      case 'confirmed':
        return 'Confirmed';

      case 'processing':
        return 'Processing';

      case 'shipped':
        return 'Shipped';

      case 'out_for_delivery':
        return 'Out for Delivery';

      case 'delivered':
        return 'Delivered';

      case 'cancelled':
        return 'Cancelled';

      case 'rejected':
        return 'Rejected';

      case 'pending':
        return 'Pending';

      case 'paid':
        return 'Paid';

      case 'failed':
        return 'Failed';

      case 'refunded':
        return 'Refunded';

      default:
        if (status.isEmpty) {
          return 'Unknown';
        }

        return status[0].toUpperCase() +
            status.substring(1);
    }
  }

  // ============================================================
  // FORMAT PAYMENT METHOD
  // ============================================================

  String _formatPaymentMethod(
    String method,
  ) {
    switch (method.toLowerCase()) {
      case 'cod':
        return 'Cash on Delivery';

      case 'online':
        return 'Online Payment';

      case 'upi':
        return 'UPI';

      case 'card':
        return 'Card';

      default:
        return method.isEmpty
            ? 'Cash on Delivery'
            : method.toUpperCase();
    }
  }
}