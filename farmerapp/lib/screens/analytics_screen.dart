import 'package:flutter/material.dart';

import '../models/crop.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<CropModel> crops;
  final List<Map<String, dynamic>> orders;

  const AnalyticsScreen({
    super.key,
    required this.crops,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final totalViews = crops.fold<int>(
      0,
      (sum, crop) => sum + crop.views,
    );

    final availableStock =
        crops.fold<double>(
      0,
      (sum, crop) => sum + crop.quantity,
    );

    final totalSales =
        orders.fold<double>(
      0,
      (sum, order) {
        if (order['orderStatus'] ==
            'cancelled') {
          return sum;
        }

        return sum +
            (order['totalAmount'] ?? 0)
                .toDouble();
      },
    );

    final deliveredOrders =
        orders.where(
      (order) =>
          order['orderStatus'] ==
          'delivered',
    ).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Farm Performance',
              style: TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _metric(
              'Total Crops',
              '${crops.length}',
              Icons.eco,
            ),

            _metric(
              'Total Orders',
              '${orders.length}',
              Icons.shopping_bag,
            ),

            _metric(
              'Total Sales',
              '₹${totalSales.toStringAsFixed(0)}',
              Icons.currency_rupee,
            ),

            _metric(
              'Crop Views',
              '$totalViews',
              Icons.visibility,
            ),

            _metric(
              'Available Stock',
              '${availableStock.toStringAsFixed(0)} kg',
              Icons.inventory_2,
            ),

            _metric(
              'Delivered Orders',
              '$deliveredOrders',
              Icons.local_shipping,
            ),

            const SizedBox(height: 25),

            const Text(
              'Your Crops',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            if (crops.isEmpty)
              const Text(
                'No crop data available.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

            ...crops.map(
              (crop) => Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 10,
                ),
                padding:
                    const EdgeInsets.all(15),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.eco,
                      color:
                          Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        crop.name,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${crop.views} views',
                      style:
                          const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFE8F5E9),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color:
                  const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
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
    );
  }
}