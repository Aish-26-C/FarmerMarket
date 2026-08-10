import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/crop.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class MyCropsScreen extends StatefulWidget {
  const MyCropsScreen({super.key});

  @override
  State<MyCropsScreen> createState() =>
      _MyCropsScreenState();
}

class _MyCropsScreenState
    extends State<MyCropsScreen> {
  List<CropModel> _crops = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    try {
      final auth =
          context.read<AuthProvider>();

      final crops =
          await ApiService.getCrops();

      final mine = crops
          .where(
            (crop) =>
                crop.farmerId ==
                auth.user?.id,
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _crops = mine;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Crops',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCrops,
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _crops.isEmpty
                ? const Center(
                    child: Text(
                      'No crops added yet.',
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.all(16),
                    itemCount: _crops.length,
                    itemBuilder:
                        (context, index) {
                      final crop =
                          _crops[index];

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
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 85,
                              height: 85,
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
                                image: crop.images
                                        .isNotEmpty
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
                              child: crop.images
                                      .isEmpty
                                  ? const Icon(
                                      Icons.eco,
                                      size: 38,
                                      color:
                                          Color(
                                        0xFF2E7D32,
                                      ),
                                    )
                                  : null,
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
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 5),
                                  Text(
                                    '₹${crop.price.toStringAsFixed(0)} / ${crop.unit}',
                                  ),
                                  Text(
                                    '${crop.quantity.toStringAsFixed(0)} ${crop.unit} available',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        crop.isOrganic
                                            ? Icons
                                                .verified
                                            : Icons
                                                .eco,
                                        size: 16,
                                        color:
                                            const Color(
                                          0xFF2E7D32,
                                        ),
                                      ),
                                      const SizedBox(
                                          width: 4),
                                      Text(
                                        crop.isOrganic
                                            ? 'Organic'
                                            : 'Regular',
                                        style:
                                            const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}