import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/crop.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'add_crop_screen.dart';
import 'analytics_screen.dart';
import 'farmer_orders_screen.dart';
import 'login_screen.dart';
import 'my_crops_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() =>
      _FarmerDashboardState();
}

class _FarmerDashboardState
    extends State<FarmerDashboard> {
  List<CropModel> crops = [];
  List<Map<String, dynamic>> orders = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  // ============================================================
  // LOAD DASHBOARD DATA
  // ============================================================

  Future<void> loadDashboard() async {
    try {
      final auth = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      final token = auth.token;

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        return;
      }

      final cropData =
          await ApiService.getMyCrops(token);

      final orderData =
          await ApiService.getFarmerOrders(token);

      if (!mounted) return;

      setState(() {
        crops = cropData;
        orders = orderData;
        loading = false;
      });
    } catch (e) {
      debugPrint(
        'Dashboard error: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  // ============================================================
  // ADD ITEM
  // ============================================================

  Future<void> addItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddCropScreen(),
      ),
    );

    await loadDashboard();
  }

  // ============================================================
  // MY CROPS
  // ============================================================

  Future<void> openMyCrops() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const MyCropsScreen(),
      ),
    );

    await loadDashboard();
  }

  // ============================================================
  // ORDERS
  // ============================================================

  Future<void> openOrders() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const FarmerOrdersScreen(),
      ),
    );

    await loadDashboard();
  }

  // ============================================================
  // ANALYTICS
  // ============================================================

  void openAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalyticsScreen(
          crops: crops,
          orders: orders,
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final auth =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    await auth.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final auth =
        Provider.of<AuthProvider>(
      context,
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F8F3),

      appBar: AppBar(
        title: const Text(
          'Farmer Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

        actions: [
          IconButton(
            onPressed: loadDashboard,
            icon: const Icon(
              Icons.refresh,
            ),
          ),

          IconButton(
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      // ========================================================
      // SCROLLABLE BODY
      // ========================================================

      body: RefreshIndicator(
        onRefresh: loadDashboard,

        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          padding:
              const EdgeInsets.all(20),

          children: [
            // ==================================================
            // GREETING
            // ==================================================

            Text(
              'Hello, ${auth.user?.name ?? "Farmer"} 👋',

              style: const TextStyle(
                fontSize: 27,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Manage your farm and products',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // MANAGE FARM
            // ==================================================

            const Text(
              'Manage Your Farm',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // ROW 1
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: bigActionButton(
                    title: 'Add Item',
                    subtitle:
                        'Add a new crop',
                    icon:
                        Icons.add_circle,
                    color:
                        const Color(
                      0xFF2E7D32,
                    ),
                    onTap: addItem,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: bigActionButton(
                    title: 'My Crops',
                    subtitle:
                        'View your items',
                    icon: Icons.eco,
                    color:
                        const Color(
                      0xFF558B2F,
                    ),
                    onTap:
                        openMyCrops,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // ROW 2
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: bigActionButton(
                    title: 'Orders',
                    subtitle:
                        'Buyer orders',
                    icon:
                        Icons.shopping_bag,
                    color:
                        const Color(
                      0xFF1565C0,
                    ),
                    onTap:
                        openOrders,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: bigActionButton(
                    title: 'Analytics',
                    subtitle:
                        'Farm performance',
                    icon:
                        Icons.analytics,
                    color:
                        const Color(
                      0xFF6A1B9A,
                    ),
                    onTap:
                        openAnalytics,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ==================================================
            // OVERVIEW
            // ==================================================

            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: statCard(
                    'Crops',
                    crops.length
                        .toString(),
                    Icons.eco,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: statCard(
                    'Orders',
                    orders.length
                        .toString(),
                    Icons.shopping_bag,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: statCard(
                    'Views',
                    totalViews(),
                    Icons.visibility,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: statCard(
                    'Sales',
                    '₹${totalSales()}',
                    Icons.currency_rupee,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ==================================================
            // MY CROPS
            // ==================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [
                const Text(
                  'My Crops',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                TextButton(
                  onPressed:
                      openMyCrops,
                  child:
                      const Text(
                    'View All',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ==================================================
            // CROPS LIST
            // ==================================================

            buildCrops(),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ========================================================
      // FLOATING ADD BUTTON
      // ========================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: addItem,

        backgroundColor:
            const Color(0xFF2E7D32),

        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),

        label: const Text(
          'Add Item',
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BIG ACTION BUTTON
  // ============================================================

  Widget bigActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(18),

      child: Container(
        height: 135,

        padding:
            const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(
                alpha: 0.06,
              ),

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
            Container(
              width: 50,
              height: 50,

              decoration:
                  BoxDecoration(
                color:
                    color.withValues(
                  alpha: 0.12,
                ),

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),

              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const Spacer(),

            Text(
              title,

              style:
                  const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,

              style:
                  const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color:
                const Color(0xFF2E7D32),
          ),

          const SizedBox(height: 10),

          Text(
            value,

            style:
                const TextStyle(
              fontSize: 23,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(
            title,

            style:
                const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CROPS
  // ============================================================

  Widget buildCrops() {
    if (loading) {
      return Container(
        height: 150,

        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),

        child: const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (crops.isEmpty) {
      return Container(
        width: double.infinity,

        padding:
            const EdgeInsets.all(25),

        decoration:
            BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),

        child: Column(
          children: [
            const Icon(
              Icons.eco_outlined,
              size: 55,
              color: Colors.grey,
            ),

            const SizedBox(height: 10),

            const Text(
              'No items added yet',

              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: addItem,

              icon: const Icon(
                Icons.add,
              ),

              label: const Text(
                'Add Item',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: crops
          .take(5)
          .map(
            (crop) =>
                cropCard(crop),
          )
          .toList(),
    );
  }

  // ============================================================
  // CROP CARD
  // ============================================================

  Widget cropCard(
    CropModel crop,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(15),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE8F5E9,
              ),

              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: const Icon(
              Icons.eco,

              color:
                  Color(0xFF2E7D32),

              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  crop.name,

                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${crop.quantity.toStringAsFixed(0)} ${crop.unit}',

                  style:
                      const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₹${crop.price.toStringAsFixed(0)}',

            style:
                const TextStyle(
              fontSize: 18,
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
  // TOTAL VIEWS
  // ============================================================

  String totalViews() {
    int total = 0;

    for (final crop in crops) {
      total += crop.views;
    }

    return total.toString();
  }

  // ============================================================
  // TOTAL SALES
  // ============================================================

  String totalSales() {
    double total = 0;

    for (final order in orders) {
      if (order['orderStatus'] ==
          'cancelled') {
        continue;
      }

      final amount =
          order['totalAmount'];

      if (amount is num) {
        total +=
            amount.toDouble();
      }
    }

    return total.toStringAsFixed(0);
  }
}