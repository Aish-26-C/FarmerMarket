import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'buyer_dashboard.dart';
import 'farmer_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _obscurePassword = true;

  String _selectedRole = 'buyer';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await auth.login(
      email: _emailController.text.trim(),
      password:
          _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      if (auth.user?.role == 'farmer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const FarmerDashboard(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const BuyerDashboard(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid email or password',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // LOGO
                Center(
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration:
                        BoxDecoration(
                      color: const Color(
                        0xFFE8F5E9,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        26,
                      ),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 46,
                      color:
                          Color(0xFF2E7D32),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Center(
                  child: Text(
                    'Farmer Market',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF18321B),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Farm fresh. Direct to you.',
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 42),

                const Text(
                  'Welcome back 👋',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Login to continue to Farmer Market',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 28),

                // ROLE SELECTION
                const Text(
                  'I am a',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child:
                          _roleButton(
                        title: 'Buyer',
                        icon:
                            Icons.shopping_bag,
                        value: 'buyer',
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                          _roleButton(
                        title: 'Farmer',
                        icon:
                            Icons.agriculture,
                        value: 'farmer',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // EMAIL
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

                // PASSWORD
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
                            ? Icons
                                .visibility_off
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
                        value.isEmpty) {
                      return 'Enter your password';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        auth.isLoading
                            ? null
                            : _login,
                    child:
                        auth.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Login',
                                style:
                                    TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                  ),
                ),

                const SizedBox(height: 24),

                // REGISTER
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'Fresh produce • Fair prices • Direct connection',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                      fontSize: 12,
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

  Widget _roleButton({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final selected =
        _selectedRole == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
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
              size: 30,
              color: selected
                  ? const Color(0xFF2E7D32)
                  : Colors.grey,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight:
                    FontWeight.w600,
                color: selected
                    ? const Color(
                        0xFF2E7D32,
                      )
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}