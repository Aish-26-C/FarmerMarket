import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

import '../models/crop.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
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

  Future<void> _loadCrops() async {
    try {
      final crops =
          await ApiService.getCrops(
        search: _search,
      );

      if (!mounted) return;

      setState(() {
        _crops = crops;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

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
        actions: [
	Consumer<CartProvider>(
  builder: (context, cart, child) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.shopping_cart_outlined,
          ),
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
                style: const TextStyle(
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
          
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () async {
              await auth.logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCrops,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
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
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                onChanged: (value) {
                  _search = value;

                  Future.delayed(
                    const Duration(
                      milliseconds: 500,
                    ),
                    () {
                      if (_search == value) {
                        _loadCrops();
                      }
                    },
                  );
                },
                decoration:
                    const InputDecoration(
                  hintText:
                      'Search crops...',
                  prefixIcon:
                      Icon(Icons.search),
                ),
              ),

              const SizedBox(height: 25),

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
                    style: const TextStyle(
                      color:
                          Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              if (_loading)
                const Center(
                  child:
                      CircularProgressIndicator(),
                )
              else if (_crops.isEmpty)
                const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.all(40),
                    child: Text(
                      'No crops found.',
                    ),
                  ),
                )
              else
                ..._crops.map(
                  (crop) =>
                      _cropCard(crop),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cropCard(
    CropModel crop,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(
                0xFFE8F5E9,
              ),
              borderRadius:
                  BorderRadius.circular(16),
              image:
                  crop.images.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                            'http://10.0.2.2:3000${crop.images.first}',
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child:
                crop.images.isEmpty
                    ? const Icon(
                        Icons.eco,
                        size: 40,
                        color:
                            Color(0xFF2E7D32),
                      )
                    : null,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  crop.name,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  crop.farmerName,
                  style:
                      const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '₹${crop.price.toStringAsFixed(0)} / ${crop.unit}',
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${crop.quantity.toStringAsFixed(0)} ${crop.unit} available',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
			const SizedBox(height: 8),

SizedBox(
  height: 38,
  child: ElevatedButton.icon(
    onPressed: () {
      context
          .read<CartProvider>()
          .addToCart(crop);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${crop.name} added to cart',
          ),
          duration:
              const Duration(seconds: 1),
        ),
      );
    },
    icon: const Icon(
      Icons.add_shopping_cart,
      size: 18,
    ),
    label: const Text(
      'Add to Cart',
    ),
    style: ElevatedButton.styleFrom(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      minimumSize: Size.zero,
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