import "dart:developer" as developer;
import "package:flutter/material.dart";

class SocketService extends ChangeNotifier {
  bool _isConnected = false;
  String? _token;

  bool get isConnected => _isConnected;
  static const String baseUrl = "http://localhost:6014";

  void connect(String token) {
    _token = token;
    developer.log("📡 SocketService: Connection initiated (simplified version)");
    _isConnected = false;
    notifyListeners();
  }

  void updateLocation(double latitude, double longitude) {
    developer.log("📍 SocketService: Location update placeholder");
  }

  void updateStatus(String status) {
    developer.log("🔄 SocketService: Status update placeholder");
  }

  void acceptOrder(String orderId) {
    developer.log("🎯 SocketService: Accept order placeholder");
  }

  void updateOrderStatus(String orderId, String status) {
    developer.log("📊 SocketService: Order status update placeholder");
  }

  void sendMessage(String orderId, String message, String to) {
    developer.log("💬 SocketService: Send message placeholder");
  }

  void disconnect() {
    _isConnected = false;
    _token = null;
    notifyListeners();
    developer.log("🔌 SocketService: Disconnected");
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
