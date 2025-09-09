import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class PartnerProvider extends ChangeNotifier {
  // Base URL for API calls
  static const String baseUrl = 'http://localhost:6014/api/delivery';

  // Partner status
  bool _isOnline = false;
  bool _isLoading = false;
  String? _error;

  // Partner profile data
  Map<String, dynamic>? _partnerProfile;
  Map<String, dynamic>? _earnings;
  Map<String, dynamic>? _stats;

  // Location data
  double? _currentLatitude;
  double? _currentLongitude;

  // Getters
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get partnerProfile => _partnerProfile;
  Map<String, dynamic>? get earnings => _earnings;
  Map<String, dynamic>? get stats => _stats;
  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;

  // Initialize provider
  PartnerProvider() {
    _loadInitialData();
  }

  // Load initial data when provider is created
  Future<void> _loadInitialData() async {
    await getProfile();
    await getEarnings();
    await getStats();
  }

  // Toggle online/offline status
  Future<bool> toggleAvailability() async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final box = await Hive.openBox('auth');
      final token = box.get('token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final newStatus = _isOnline ? 'offline' : 'online';

      final response = await http.put(
        Uri.parse('$baseUrl/partner/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _isOnline = !_isOnline;

          // Update partner profile with new status
          if (_partnerProfile != null) {
            _partnerProfile!['isAvailable'] = _isOnline;
            _partnerProfile!['status'] = newStatus;
          }

          _isLoading = false;
          notifyListeners();

          print('✅ Status updated successfully: $newStatus');
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to update status');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('❌ Toggle availability error: $e');
      return false;
    }
  }

  // Update location
  Future<bool> updateLocation(double latitude, double longitude) async {
    try {
      final box = await Hive.openBox('auth');
      final token = box.get('token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/partner/location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'latitude': latitude, 'longitude': longitude}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _currentLatitude = latitude;
          _currentLongitude = longitude;
          notifyListeners();
          print('📍 Location updated: ($latitude, $longitude)');
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to update location');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update location');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('❌ Update location error: $e');
      return false;
    }
  }

  // Get partner profile
  Future<bool> getProfile() async {
    try {
      final box = await Hive.openBox('auth');
      final token = box.get('token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/partner/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _partnerProfile = data['data']['deliveryPartner'];
          _isOnline = _partnerProfile?['isAvailable'] ?? false;
          notifyListeners();
          print('✅ Profile loaded successfully');
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to get profile');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('❌ Get profile error: $e');
      return false;
    }
  }

  // Get earnings data
  Future<bool> getEarnings() async {
    try {
      final box = await Hive.openBox('auth');
      final token = box.get('token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/partner/earnings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _earnings = data['data']['earnings'];
          _stats = data['data']['stats'];
          notifyListeners();
          print('✅ Earnings loaded successfully');
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to get earnings');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get earnings');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('❌ Get earnings error: $e');
      return false;
    }
  }

  // Get statistics
  Future<bool> getStats() async {
    try {
      final box = await Hive.openBox('auth');
      final token = box.get('token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/partner/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _stats = data['data']['stats'];
          notifyListeners();
          print('✅ Stats loaded successfully');
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to get stats');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get stats');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('❌ Get stats error: $e');
      return false;
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await getProfile();
    await getEarnings();
    await getStats();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Update online status directly (for socket updates)
  void updateOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    if (_partnerProfile != null) {
      _partnerProfile!['isAvailable'] = isOnline;
      _partnerProfile!['status'] = isOnline ? 'online' : 'offline';
    }
    notifyListeners();
  }

  // Get status text for UI
  String get statusText {
    if (_isLoading) return 'Updating...';
    return _isOnline ? 'Online' : 'Offline';
  }

  // Get status color for UI
  Color get statusColor {
    if (_isLoading) return Colors.orange;
    return _isOnline ? Colors.green : Colors.grey;
  }

  // Format earnings for display
  String formatEarnings(double amount) {
    return '\₹${amount.toStringAsFixed(2)}';
  }

  // Get today's earnings
  String get todayEarnings {
    if (_earnings == null) return '\₹0.00';
    return formatEarnings((_earnings!['today'] ?? 0.0).toDouble());
  }

  // Get weekly earnings
  String get weeklyEarnings {
    if (_earnings == null) return '\₹0.00';
    return formatEarnings((_earnings!['weekly'] ?? 0.0).toDouble());
  }

  // Get monthly earnings
  String get monthlyEarnings {
    if (_earnings == null) return '\₹0.00';
    return formatEarnings((_earnings!['monthly'] ?? 0.0).toDouble());
  }

  // Get total earnings
  String get totalEarnings {
    if (_earnings == null) return '\₹0.00';
    return formatEarnings((_earnings!['total'] ?? 0.0).toDouble());
  }

  // Get total deliveries
  int get totalDeliveries {
    if (_stats == null) return 0;
    return (_stats!['totalDeliveries'] ?? 0);
  }

  // Get completed deliveries
  int get completedDeliveries {
    if (_stats == null) return 0;
    return (_stats!['completedDeliveries'] ?? 0);
  }

  // Get rating
  double get rating {
    if (_stats == null) return 0.0;
    return (_stats!['averageRating'] ?? 0.0).toDouble();
  }
}
