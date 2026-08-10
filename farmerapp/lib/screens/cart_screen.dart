import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add fresh produce from farmers.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: 15,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE8F5E9,
                                ),
                                borderRadius:
                                    BorderRadius.circular(14),
                                image: item.crop.images
                                        .isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          'http://10.0.2.2:3000${item.crop.images.first}',
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: item.crop.images.isEmpty
                                  ? const Icon(
                                      Icons.eco,
                                      color:
                                          Color(0xFF2E7D32),
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.crop.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    '₹${item.crop.price.toStringAsFixed(0)} / ${item.crop.unit}',
                                    style:
                                        const TextStyle(
                                      color:
                                          Color(0xFF2E7D32),
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          cart
                                              .decreaseQuantity(
                                            item.crop.id,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons
                                              .remove_circle_outline,
                                        ),
                                      ),

                                      Text(
                                        '${item.quantity}',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: () {
                                          cart
                                              .increaseQuantity(
                                            item.crop.id,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons
                                              .add_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    cart.removeFromCart(
                                      item.crop.id,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  '₹${item.subtotal.toStringAsFixed(0)}',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${cart.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Checkout screen coming next.',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}