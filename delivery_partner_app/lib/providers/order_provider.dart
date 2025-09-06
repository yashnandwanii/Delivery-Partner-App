import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/delivery_order.dart';

class OrderProvider extends ChangeNotifier {
  List<DeliveryOrder> _availableOrders = [];
  List<DeliveryOrder> _myOrders = [];
  DeliveryOrder? _currentOrder;
  bool _isLoading = false;
  String? _error;
  String? _token;

  List<DeliveryOrder> get availableOrders => _availableOrders;
  List<DeliveryOrder> get myOrders => _myOrders;
  DeliveryOrder? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const String baseUrl = 'http://localhost:6013/api';

  void setToken(String? token) {
    _token = token;
  }

  Future<void> loadAvailableOrders() async {
    if (_token == null) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/available'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _availableOrders = (data['orders'] as List)
            .map((orderJson) => DeliveryOrder.fromJson(orderJson))
            .toList();
        _setLoading(false);
      } else {
        _setError('Failed to load available orders');
        _setLoading(false);
      }
    } catch (e) {
      _setError('Network error: $e');
      _setLoading(false);
    }
  }

  Future<void> loadMyOrders() async {
    if (_token == null) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/my-orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _myOrders = (data['orders'] as List)
            .map((orderJson) => DeliveryOrder.fromJson(orderJson))
            .toList();

        // Find current active order
        try {
          _currentOrder = _myOrders.firstWhere(
            (order) =>
                order.orderStatus == 'accepted' ||
                order.orderStatus == 'picked_up',
          );
        } catch (e) {
          _currentOrder = _myOrders.isNotEmpty ? _myOrders.first : null;
        }

        _setLoading(false);
      } else {
        _setError('Failed to load my orders');
        _setLoading(false);
      }
    } catch (e) {
      _setError('Network error: $e');
      _setLoading(false);
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    if (_token == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        await loadAvailableOrders();
        await loadMyOrders();
        _setLoading(false);
        return true;
      } else {
        final data = json.decode(response.body);
        _setError(data['message'] ?? 'Failed to accept order');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    if (_token == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        await loadMyOrders();
        _setLoading(false);
        return true;
      } else {
        final data = json.decode(response.body);
        _setError(data['message'] ?? 'Failed to update order status');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> pickupOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'picked_up');
  }

  Future<bool> deliverOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'delivered');
  }

  Future<void> loadOrderDetails(String orderId) async {
    if (_token == null) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentOrder = DeliveryOrder.fromJson(data['order']);
        _setLoading(false);
      } else {
        _setError('Failed to load order details');
        _setLoading(false);
      }
    } catch (e) {
      _setError('Network error: $e');
      _setLoading(false);
    }
  }

  Future<void> updateDeliveryLocation(
    String orderId,
    double latitude,
    double longitude,
  ) async {
    if (_token == null) return;

    try {
      await http.put(
        Uri.parse('$baseUrl/orders/$orderId/location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'latitude': latitude, 'longitude': longitude}),
      );
    } catch (e) {
      _setError('Failed to update delivery location: $e');
    }
  }

  void setCurrentOrder(DeliveryOrder? order) {
    _currentOrder = order;
    notifyListeners();
  }

  void clearOrders() {
    _availableOrders.clear();
    _myOrders.clear();
    _currentOrder = null;
    notifyListeners();
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
