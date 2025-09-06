import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/simple_delivery_partner.dart';

class AuthProvider extends ChangeNotifier {
  SimpleDeliveryPartner? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _token;

  SimpleDeliveryPartner? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  bool get isAuthenticated => _currentUser != null && _token != null;

  static const String baseUrl = 'http://localhost:6013/api';

  Future<void> loadStoredAuth() async {
    try {
      final box = await Hive.openBox('auth');
      _token = box.get('token');
      final userData = box.get('user');

      if (userData != null && _token != null) {
        _currentUser = userData;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load stored authentication';
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/delivery-partner/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        _currentUser = SimpleDeliveryPartner.fromJson(data['user']);

        await _storeAuth();
        _setLoading(false);
        return true;
      } else {
        _setError(data['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String vehicleType,
    required String vehicleNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/delivery-partner/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'vehicleType': vehicleType,
          'vehicleNumber': vehicleNumber,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        _token = data['token'];
        _currentUser = SimpleDeliveryPartner.fromJson(data['user']);

        await _storeAuth();
        _setLoading(false);
        return true;
      } else {
        _setError(data['message'] ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;

    final box = await Hive.openBox('auth');
    await box.clear();

    notifyListeners();
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    if (!isAuthenticated) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/delivery-partner/location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'latitude': latitude, 'longitude': longitude}),
      );

      if (response.statusCode == 200) {
        final updatedLocation = SimpleLocationModel(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
        );

        _currentUser = _currentUser?.copyWith(currentLocation: updatedLocation);

        await _storeAuth();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update location: $e');
    }
  }

  Future<void> updateStatus(String status) async {
    if (!isAuthenticated) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/delivery-partner/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        _currentUser = _currentUser?.copyWith(status: status);
        await _storeAuth();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update status: $e');
    }
  }

  Future<void> _storeAuth() async {
    final box = await Hive.openBox('auth');
    await box.put('token', _token);
    await box.put('user', _currentUser);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
