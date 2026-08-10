import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _loading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _loading;
  bool get isLoggedIn =>
      _token != null && _token!.isNotEmpty;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final data = await ApiService.login(
        email: email,
        password: password,
      );

      _token = data['token'];

      _user = UserModel.fromJson(
        Map<String, dynamic>.from(
          data['user'],
        ),
      );

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'token',
        _token!,
      );

      await prefs.setString(
        'role',
        _user!.role,
      );

      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final data = await ApiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      _token = data['token'];

      _user = UserModel.fromJson(
        Map<String, dynamic>.from(
          data['user'],
        ),
      );

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'token',
        _token!,
      );

      await prefs.setString(
        'role',
        _user!.role,
      );

      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedSession() async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedToken =
        prefs.getString('token');

    if (savedToken == null ||
        savedToken.isEmpty) {
      return;
    }

    try {
      final user =
          await ApiService.getProfile(
        savedToken,
      );

      _token = savedToken;
      _user = user;

      notifyListeners();
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('role');

    notifyListeners();
  }
}