import 'package:hive/hive.dart';

part 'delivery_order.g.dart';

@HiveType(typeId: 2)
class DeliveryOrder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String restaurantId;

  @HiveField(3)
  final String restaurantName;

  @HiveField(4)
  final List<OrderItem> orderItems;

  @HiveField(5)
  final double orderTotal;

  @HiveField(6)
  final double deliveryFee;

  @HiveField(7)
  final double grandTotal;

  @HiveField(8)
  final LocationModel pickupLocation;

  @HiveField(9)
  final LocationModel deliveryLocation;

  @HiveField(10)
  final String orderStatus;

  @HiveField(11)
  final String paymentStatus;

  @HiveField(12)
  final String paymentMethod;

  @HiveField(13)
  final DateTime orderDate;

  @HiveField(14)
  final DateTime? estimatedDeliveryTime;

  @HiveField(15)
  final DateTime? actualDeliveryTime;

  @HiveField(16)
  final String? deliveryPartnerId;

  @HiveField(17)
  final String? specialInstructions;

  @HiveField(18)
  final String customerName;

  @HiveField(19)
  final String customerPhone;

  @HiveField(20)
  final double? distance;

  DeliveryOrder({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.orderItems,
    required this.orderTotal,
    required this.deliveryFee,
    required this.grandTotal,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.orderDate,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.deliveryPartnerId,
    this.specialInstructions,
    required this.customerName,
    required this.customerPhone,
    this.distance,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      orderItems: (json['orderItems'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      orderTotal: (json['orderTotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      pickupLocation: LocationModel.fromJson(json['pickupLocation'] ?? {}),
      deliveryLocation: LocationModel.fromJson(json['deliveryLocation'] ?? {}),
      orderStatus: json['orderStatus'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.parse(json['estimatedDeliveryTime'])
          : null,
      actualDeliveryTime: json['actualDeliveryTime'] != null
          ? DateTime.parse(json['actualDeliveryTime'])
          : null,
      deliveryPartnerId: json['deliveryPartnerId'],
      specialInstructions: json['specialInstructions'],
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'orderTotal': orderTotal,
      'deliveryFee': deliveryFee,
      'grandTotal': grandTotal,
      'pickupLocation': pickupLocation.toJson(),
      'deliveryLocation': deliveryLocation.toJson(),
      'orderStatus': orderStatus,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
      'deliveryPartnerId': deliveryPartnerId,
      'specialInstructions': specialInstructions,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'distance': distance,
    };
  }
}

@HiveType(typeId: 3)
class LocationModel extends HiveObject {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String? landmark;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.landmark,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      landmark: json['landmark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'landmark': landmark,
    };
  }
}

@HiveType(typeId: 4)
class OrderItem extends HiveObject {
  @HiveField(0)
  final String foodId;

  @HiveField(1)
  final String foodName;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final List<String> additives;

  @HiveField(5)
  final String? instructions;

  OrderItem({
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.price,
    required this.additives,
    this.instructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      foodId: json['foodId'] ?? '',
      foodName: json['foodName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      additives: List<String>.from(json['additives'] ?? []),
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'quantity': quantity,
      'price': price,
      'additives': additives,
      'instructions': instructions,
    };
  }
}
