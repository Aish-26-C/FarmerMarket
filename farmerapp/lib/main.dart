import 'package:flutter/material.dart';
import 'providers/cart_provider.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/buyer_dashboard.dart';
import 'screens/farmer_dashboard.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
    ),
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
    ),
  ],
  child: const FarmerMarketApp(),
),
  );
}

class FarmerMarketApp extends StatefulWidget {
  const FarmerMarketApp({super.key});

  @override
  State<FarmerMarketApp> createState() =>
      _FarmerMarketAppState();
}

class _FarmerMarketAppState
    extends State<FarmerMarketApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<AuthProvider>()
          .loadSavedSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farmer Market',
      theme: AppTheme.lightTheme,
      home: const AppStartScreen(),
    );
  }
}

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() =>
      _AppStartScreenState();
}

class _AppStartScreenState
    extends State<AppStartScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        final auth =
            context.read<AuthProvider>();

        if (auth.isLoggedIn) {
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const LoginScreen(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFF7F8F3),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.08),                    blurRadius: 25,
                    offset:
                        const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.agriculture,
                size: 60,
                color:
                    Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Farmer Market',
              style: TextStyle(
                fontSize: 34,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF18321B),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Farm fresh. Direct to you.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            const SizedBox(
              width: 28,
              height: 28,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2.5,
                color:
                    Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}