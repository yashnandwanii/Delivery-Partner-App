import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService extends ChangeNotifier {
  io.Socket? _socket;
  bool _isConnected = false;
  String? _token;

  bool get isConnected => _isConnected;
  io.Socket? get socket => _socket;

  static const String baseUrl = 'http://localhost:6014';

  void connect(String token) {
    _token = token;

    try {
      _socket = io.io(
        baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': 'Bearer $token'})
            .enableAutoConnect()
            .build(),
      );

      _socket?.onConnect((_) {
        developer.log('✅ Socket connected successfully');
        _isConnected = true;
        notifyListeners();

        // Join delivery partner room for personalized notifications
        _socket?.emit('join_delivery_partner', _token);
      });

      _socket?.onDisconnect((_) {
        developer.log('❌ Socket disconnected');
        _isConnected = false;
        notifyListeners();
      });

      _socket?.onError((error) {
        developer.log('❌ Socket error: $error');
        _isConnected = false;
        notifyListeners();
      });

      _socket?.onReconnect((_) {
        developer.log('🔄 Socket reconnected');
        _isConnected = true;
        notifyListeners();
      });

      // Listen for delivery-specific events
      _setupDeliveryListeners();
    } catch (e) {
      developer.log('❌ Socket connection failed: $e');
    }
  }

  void _setupDeliveryListeners() {
    // New order available
    _socket?.on('new_order_available', (data) {
      developer.log('📦 New order available: $data');
      notifyListeners();
      // This will be handled by OrderProvider
    });

    // Order assigned to you
    _socket?.on('order_assigned', (data) {
      developer.log('🎯 Order assigned: $data');
      notifyListeners();
    });

    // Order cancelled
    _socket?.on('order_cancelled', (data) {
      developer.log('❌ Order cancelled: $data');
      notifyListeners();
    });

    // Order status updates
    _socket?.on('order_status_update', (data) {
      developer.log('📊 Order status update: $data');
      notifyListeners();
    });

    // Delivery partner location update request
    _socket?.on('request_location_update', (data) {
      developer.log('📍 Location update requested: $data');
      notifyListeners();
    });

    // New message/instruction from restaurant or customer
    _socket?.on('new_message', (data) {
      developer.log('💬 New message: $data');
      notifyListeners();
    });

    // Earnings update
    _socket?.on('earnings_update', (data) {
      developer.log('💰 Earnings update: $data');
      notifyListeners();
    });
  }

  // Emit events to server
  void updateLocation(double latitude, double longitude) {
    if (_isConnected && _socket != null) {
      _socket!.emit('location_update', {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void updateStatus(String status) {
    if (_isConnected && _socket != null) {
      _socket!.emit('status_update', {
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void acceptOrder(String orderId) {
    if (_isConnected && _socket != null) {
      _socket!.emit('accept_order', {
        'orderId': orderId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void updateOrderStatus(String orderId, String status) {
    if (_isConnected && _socket != null) {
      _socket!.emit('order_status_update', {
        'orderId': orderId,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void sendMessage(String orderId, String message, String to) {
    if (_isConnected && _socket != null) {
      _socket!.emit('send_message', {
        'orderId': orderId,
        'message': message,
        'to': to, // 'customer' or 'restaurant'
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      _token = null;
      notifyListeners();
      developer.log('🔌 Socket disconnected manually');
    }
  }

  // Getter to access token if needed
  String? get token => _token;

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
