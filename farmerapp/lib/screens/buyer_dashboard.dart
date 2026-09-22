import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/crop.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

import 'cart_screen.dart';
import 'buyer_orders_screen.dart';
import 'login_screen.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() =>
      _BuyerDashboardState();
}

class _BuyerDashboardState
    extends State<BuyerDashboard> {
  List<CropModel> _crops = [];

  bool _loading = true;

  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  // ============================================================
  // LOAD CROPS
  // ============================================================

  Future<void> _loadCrops() async {
    try {
      final crops = await ApiService.getCrops(
        search: _search,
      );

      if (!mounted) return;

      setState(() {
        _crops = crops;
        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'Load crops error: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load crops: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // OPEN MY ORDERS
  // ============================================================

  void _openMyOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const BuyerOrdersScreen(),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final auth =
        context.read<AuthProvider>();

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
        Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Farmer Market',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // ======================================================
          // CART BUTTON
          // ======================================================

          Consumer<CartProvider>(
            builder: (
              context,
              cart,
              child,
            ) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                    ),
                    tooltip: 'Cart',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CartScreen(),
                        ),
                      );
                    },
                  ),

                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 5,
                      child: Container(
                        padding:
                            const EdgeInsets.all(4),
                        decoration:
                            const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // ======================================================
          // LOGOUT
          // ======================================================

          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),

      backgroundColor:
          const Color(0xFFF7F9F5),

      // ==========================================================
      // BODY
      // ==========================================================

      body: RefreshIndicator(
        onRefresh: _loadCrops,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // GREETING
              // ==================================================

              Text(
                'Hello, ${auth.user?.name ?? "Buyer"} 👋',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Fresh produce directly from farmers.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // SEARCH
              // ==================================================

              TextField(
                onChanged: (value) {
                  _search = value;

                  Future.delayed(
                    const Duration(
                      milliseconds: 500,
                    ),
                    () {
                      if (!mounted) return;

                      if (_search == value) {
                        _loadCrops();
                      }
                    },
                  );
                },
                decoration:
                    InputDecoration(
                  hintText:
                      'Search crops...',
                  prefixIcon:
                      const Icon(
                    Icons.search,
                  ),
                  suffixIcon:
                      _search.isNotEmpty
                          ? IconButton(
                              icon:
                                  const Icon(
                                Icons.clear,
                              ),
                              onPressed: () {
                                setState(() {
                                  _search = '';
                                });

                                _loadCrops();
                              },
                            )
                          : null,
                  filled: true,
                  fillColor:
                      Colors.white,
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // MY ORDERS
              // ==================================================

              GestureDetector(
                onTap: _openMyOrders,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(
                          alpha: 0.05,
                        ),
                        blurRadius: 8,
                        offset:
                            const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ------------------------------------------
                      // ICON
                      // ------------------------------------------

                      Container(
                        width: 52,
                        height: 52,
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
                        child:
                            const Icon(
                          Icons
                              .receipt_long_outlined,
                          color:
                              Color(0xFF2E7D32),
                          size: 29,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      // ------------------------------------------
                      // TEXT
                      // ------------------------------------------

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'My Orders',
                              style:
                                  TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Track your purchases and delivery status',
                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ------------------------------------------
                      // ARROW
                      // ------------------------------------------

                      const Icon(
                        Icons
                            .arrow_forward_ios,
                        size: 18,
                        color:
                            Color(0xFF2E7D32),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // FRESH FROM FARMS HEADER
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  const Text(
                    'Fresh from farms',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${_crops.length} items',
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF2E7D32),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ==================================================
              // CROPS
              // ==================================================

              if (_loading)
                const Center(
                  child:
                      Padding(
                    padding:
                        EdgeInsets.all(40),
                    child:
                        CircularProgressIndicator(),
                  ),
                )
              else if (_crops.isEmpty)
                const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons
                              .eco_outlined,
                          size: 60,
                          color:
                              Colors.grey,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          'No crops found.',
                          style:
                              TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._crops.map(
                  (crop) =>
                      _cropCard(crop),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CROP CARD
  // ============================================================

  Widget _cropCard(
    CropModel crop,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 15,
      ),
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.04,
            ),
            blurRadius: 8,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ======================================================
          // CROP IMAGE
          // ======================================================

          Container(
            width: 90,
            height: 90,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE8F5E9,
              ),
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
              image:
                  crop.images.isNotEmpty
                      ? DecorationImage(
                          image:
                              NetworkImage(
                            'http://10.0.2.2:3000${crop.images.first}',
                          ),
                          fit:
                              BoxFit.cover,
                        )
                      : null,
            ),
            child:
                crop.images.isEmpty
                    ? const Icon(
                        Icons.eco,
                        size: 40,
                        color:
                            Color(
                          0xFF2E7D32,
                        ),
                      )
                    : null,
          ),

          const SizedBox(
            width: 15,
          ),

          // ======================================================
          // CROP DETAILS
          // ======================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                // ----------------------------------------------
                // CROP NAME
                // ----------------------------------------------

                Text(
                  crop.name,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                // ----------------------------------------------
                // FARMER NAME
                // ----------------------------------------------

                Text(
                  crop.farmerName,
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                // ----------------------------------------------
                // PRICE
                // ----------------------------------------------

                Text(
                  '₹${crop.price.toStringAsFixed(0)} / ${crop.unit}',
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(
                      0xFF2E7D32,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                // ----------------------------------------------
                // AVAILABLE QUANTITY
                // ----------------------------------------------

                Text(
                  '${crop.quantity.toStringAsFixed(0)} ${crop.unit} available',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                // ----------------------------------------------
                // ADD TO CART
                // ----------------------------------------------

                SizedBox(
                  height: 38,
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<
                              CartProvider>()
                          .addToCart(
                            crop,
                          );

                      ScaffoldMessenger
                              .of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content:
                              Text(
                            '${crop.name} added to cart',
                          ),
                          duration:
                              const Duration(
                            seconds: 1,
                          ),
                        ),
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .add_shopping_cart,
                      size: 18,
                    ),
                    label:
                        const Text(
                      'Add to Cart',
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            12,
                      ),
                      minimumSize:
                          Size.zero,
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
}