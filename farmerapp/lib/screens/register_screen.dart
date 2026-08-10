import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'buyer_dashboard.dart';
import 'farmer_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _phoneController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  String _role = 'buyer';

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password:
          _passwordController.text.trim(),
      role: _role,
    );

    if (!mounted) return;

    if (success) {
      if (_role == 'farmer') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const FarmerDashboard(),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const BuyerDashboard(),
          ),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Registration failed. Please check your details.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth =
        Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join Farmer Market 🌱',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Create your account and get started.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Account type',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _roleButton(
                        'Buyer',
                        Icons.shopping_cart,
                        'buyer',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _roleButton(
                        'Farmer',
                        Icons.agriculture,
                        'farmer',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                TextFormField(
                  controller:
                      _nameController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon:
                        Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter your name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                        Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter your email';
                    }

                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _phoneController,
                  keyboardType:
                      TextInputType.phone,
                  maxLength: 10,
                  decoration:
                      const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon:
                        Icon(Icons.phone_outlined),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.length != 10) {
                      return 'Enter a valid 10-digit phone number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _passwordController,
                  obscureText:
                      _obscurePassword,
                  decoration:
                      InputDecoration(
                    labelText: 'Password',
                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon:
                        IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        auth.isLoading
                            ? null
                            : _register,
                    child:
                        auth.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style:
                                    TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Already have an account? Login',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleButton(
    String title,
    IconData icon,
    String value,
  ) {
    final selected = _role == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _role = value;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(
          vertical: 16,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? const Color(0xFFE8F5E9)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF2E7D32)
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFF2E7D32)
                  : Colors.grey,
            ),
            const SizedBox(height: 6),
            Text(title),
          ],
        ),
      ),
    );
  }
}