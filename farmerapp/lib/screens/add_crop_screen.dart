import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _priceController =
      TextEditingController();

  final TextEditingController _quantityController =
      TextEditingController();

  final TextEditingController _cityController =
      TextEditingController(text: 'Bengaluru');

  final TextEditingController _stateController =
      TextEditingController(text: 'Karnataka');

  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;

  String _selectedCategory = 'vegetables';
  String _selectedUnit = 'kg';

  bool _isOrganic = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _cityController.dispose();
    _stateController.dispose();

    super.dispose();
  }

  // ============================================================
  // SELECT IMAGE
  // ============================================================

  Future<void> _selectImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select image: $e'),
        ),
      );
    }
  }

  // ============================================================
  // TAKE PHOTO
  // ============================================================

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open camera: $e'),
        ),
      );
    }
  }

  // ============================================================
  // IMAGE OPTIONS
  // ============================================================

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                ),
                title: const Text(
                  'Choose from Gallery',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _selectImage();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                ),
                title: const Text(
                  'Take a Photo',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Remove Image',
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SAVE CROP
  // ============================================================

  Future<void> _saveCrop() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final String? token = authProvider.token;

    if (token == null || token.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Session expired. Please login again.',
          ),
        ),
      );

      return;
    }

    final double? price = double.tryParse(
      _priceController.text.trim(),
    );

    final double? quantity = double.tryParse(
      _quantityController.text.trim(),
    );

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid price.',
          ),
        ),
      );

      return;
    }

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid quantity.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await ApiService.addCrop(
        token: token,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        price: price,
        quantity: quantity,
        unit: _selectedUnit,
        isOrganic: _isOrganic,
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        imagePath: _selectedImage?.path,
      );

      if (!mounted) return;

      final String message =
          result['message']?.toString() ??
              'Crop added successfully';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add crop: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF2E7D32),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Crop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // IMPORTANT:
      // This makes the COMPLETE form scrollable.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(20),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),

                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // ==================================================
                      // IMAGE
                      // ==================================================

                      const Text(
                        'Crop Image',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: _showImageOptions,

                        child: Container(
                          width: double.infinity,
                          height: 210,

                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFE8F5E9),
                            borderRadius:
                                BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  Colors.green.shade200,
                            ),
                          ),

                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    18,
                                  ),

                                  child: Image.file(
                                    _selectedImage!,
                                    width:
                                        double.infinity,
                                    height: 210,
                                    fit: BoxFit.cover,
                                  ),
                                )

                              : Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,

                                  children: [
                                    Icon(
                                      Icons
                                          .add_photo_alternate_outlined,
                                      size: 60,
                                      color:
                                          Colors.green.shade700,
                                    ),

                                    const SizedBox(
                                      height: 12,
                                    ),

                                    const Text(
                                      'Add Crop Image',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 5,
                                    ),

                                    Text(
                                      'Tap to choose from gallery',
                                      style: TextStyle(
                                        color:
                                            Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ==================================================
                      // CROP INFORMATION
                      // ==================================================

                      const Text(
                        'Crop Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _nameController,
                        textInputAction:
                            TextInputAction.next,

                        decoration:
                            _inputDecoration(
                          label: 'Crop Name',
                          hint: 'Example: Tomatoes',
                          icon: Icons.eco_outlined,
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter crop name';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // CATEGORY
                      // ==================================================

                      DropdownButtonFormField<String>(
                        initialValue:
                            _selectedCategory,

                        decoration:
                            _inputDecoration(
                          label: 'Category',
                          icon:
                              Icons.category_outlined,
                        ),

                        items: const [
                          DropdownMenuItem(
                            value: 'vegetables',
                            child:
                                Text('Vegetables'),
                          ),
                          DropdownMenuItem(
                            value: 'fruits',
                            child: Text('Fruits'),
                          ),
                          DropdownMenuItem(
                            value: 'grains',
                            child: Text('Grains'),
                          ),
                          DropdownMenuItem(
                            value: 'pulses',
                            child: Text('Pulses'),
                          ),
                          DropdownMenuItem(
                            value: 'spices',
                            child: Text('Spices'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Other'),
                          ),
                        ],

                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // DESCRIPTION
                      // ==================================================

                      TextFormField(
                        controller:
                            _descriptionController,
                        maxLines: 4,

                        decoration:
                            _inputDecoration(
                          label: 'Description',
                          hint:
                              'Describe your crop',
                          icon:
                              Icons.description_outlined,
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter description';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      // ==================================================
                      // PRICING & QUANTITY
                      // ==================================================

                      const Text(
                        'Pricing & Quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [

                          Expanded(
                            child: TextFormField(
                              controller:
                                  _priceController,

                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),

                              decoration:
                                  _inputDecoration(
                                label: 'Price',
                                hint: '40',
                                icon:
                                    Icons.currency_rupee,
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Required';
                                }

                                final number =
                                    double.tryParse(
                                  value,
                                );

                                if (number == null ||
                                    number <= 0) {
                                  return 'Invalid price';
                                }

                                return null;
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: TextFormField(
                              controller:
                                  _quantityController,

                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),

                              decoration:
                                  _inputDecoration(
                                label: 'Quantity',
                                hint: '100',
                                icon:
                                    Icons
                                        .inventory_2_outlined,
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Required';
                                }

                                final number =
                                    double.tryParse(
                                  value,
                                );

                                if (number == null ||
                                    number <= 0) {
                                  return 'Invalid quantity';
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // UNIT
                      // ==================================================

                      DropdownButtonFormField<String>(
                        initialValue:
                            _selectedUnit,

                        decoration:
                            _inputDecoration(
                          label: 'Unit',
                          icon:
                              Icons.scale_outlined,
                        ),

                        items: const [
                          DropdownMenuItem(
                            value: 'kg',
                            child:
                                Text('Kilogram (kg)'),
                          ),
                          DropdownMenuItem(
                            value: 'quintal',
                            child:
                                Text('Quintal'),
                          ),
                          DropdownMenuItem(
                            value: 'ton',
                            child:
                                Text('Ton'),
                          ),
                          DropdownMenuItem(
                            value: 'piece',
                            child:
                                Text('Piece'),
                          ),
                        ],

                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _selectedUnit = value;
                          });
                        },
                      ),

                      const SizedBox(height: 25),

                      // ==================================================
                      // LOCATION
                      // ==================================================

                      const Text(
                        'Farm Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller:
                            _cityController,

                        decoration:
                            _inputDecoration(
                          label: 'City',
                          hint: 'Bengaluru',
                          icon:
                              Icons.location_city,
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter city';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller:
                            _stateController,

                        decoration:
                            _inputDecoration(
                          label: 'State',
                          hint: 'Karnataka',
                          icon:
                              Icons.map_outlined,
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter state';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // ==================================================
                      // ORGANIC
                      // ==================================================

                      Card(
                        elevation: 0,
                        color:
                            const Color(0xFFE8F5E9),

                        child: SwitchListTile(
                          title: const Text(
                            'Organic Product',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          subtitle: const Text(
                            'Mark this crop as organically grown',
                          ),

                          value: _isOrganic,

                          activeThumbColor:
                              const Color(0xFF2E7D32),

                          onChanged: (value) {
                            setState(() {
                              _isOrganic = value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // SAVE CROP
                      // ==================================================

                      SizedBox(
                        width: double.infinity,
                        height: 56,

                        child: ElevatedButton(
                          onPressed:
                              _isSaving
                                  ? null
                                  : _saveCrop,

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF2E7D32),

                            foregroundColor:
                                Colors.white,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),

                          child: _isSaving
                              ? const SizedBox(
                                  width: 25,
                                  height: 25,

                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color:
                                        Colors.white,
                                  ),
                                )

                              : const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,

                                  children: [
                                    Icon(
                                      Icons
                                          .check_circle_outline,
                                    ),

                                    SizedBox(width: 10),

                                    Text(
                                      'Save Crop',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}