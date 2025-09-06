import "package:hive/hive.dart";

part "simple_delivery_partner.g.dart";

@HiveType(typeId: 0)
class SimpleDeliveryPartner extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String profileImage;

  @HiveField(5)
  final bool isActive;

  @HiveField(6)
  final bool isVerified;

  @HiveField(7)
  final String vehicleType;

  @HiveField(8)
  final String vehicleNumber;

  @HiveField(9)
  final double rating;

  @HiveField(10)
  final int totalDeliveries;

  @HiveField(11)
  final double totalEarnings;

  @HiveField(12)
  final String status;

  @HiveField(13)
  final SimpleLocationModel? currentLocation;

  @HiveField(14)
  final DateTime? lastActiveAt;

  @HiveField(15)
  final String? fcmToken;

  SimpleDeliveryPartner({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.isActive,
    required this.isVerified,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.rating,
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.status,
    this.currentLocation,
    this.lastActiveAt,
    this.fcmToken,
  });

  factory SimpleDeliveryPartner.fromJson(Map<String, dynamic> json) {
    return SimpleDeliveryPartner(
      id: json["_id"] ?? json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      profileImage: json["profileImage"] ?? "",
      isActive: json["isActive"] ?? false,
      isVerified: json["isVerified"] ?? false,
      vehicleType: json["vehicleType"] ?? "",
      vehicleNumber: json["vehicleNumber"] ?? "",
      rating: (json["rating"] as num?)?.toDouble() ?? 0.0,
      totalDeliveries: json["totalDeliveries"] ?? 0,
      totalEarnings: (json["totalEarnings"] as num?)?.toDouble() ?? 0.0,
      status: json["status"] ?? "offline",
      currentLocation: json["currentLocation"] != null
          ? SimpleLocationModel.fromJson(json["currentLocation"])
          : null,
      lastActiveAt: json["lastActiveAt"] != null
          ? DateTime.parse(json["lastActiveAt"])
          : null,
      fcmToken: json["fcmToken"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "profileImage": profileImage,
      "isActive": isActive,
      "isVerified": isVerified,
      "vehicleType": vehicleType,
      "vehicleNumber": vehicleNumber,
      "rating": rating,
      "totalDeliveries": totalDeliveries,
      "totalEarnings": totalEarnings,
      "status": status,
      "currentLocation": currentLocation?.toJson(),
      "lastActiveAt": lastActiveAt?.toIso8601String(),
      "fcmToken": fcmToken,
    };
  }

  SimpleDeliveryPartner copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    bool? isActive,
    bool? isVerified,
    String? vehicleType,
    String? vehicleNumber,
    double? rating,
    int? totalDeliveries,
    double? totalEarnings,
    String? status,
    SimpleLocationModel? currentLocation,
    DateTime? lastActiveAt,
    String? fcmToken,
  }) {
    return SimpleDeliveryPartner(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

@HiveType(typeId: 1)
class SimpleLocationModel extends HiveObject {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final String? address;

  @HiveField(3)
  final DateTime? timestamp;

  SimpleLocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.timestamp,
  });

  factory SimpleLocationModel.fromJson(Map<String, dynamic> json) {
    return SimpleLocationModel(
      latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
      longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
      address: json["address"],
      timestamp: json["timestamp"] != null
          ? DateTime.parse(json["timestamp"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "timestamp": timestamp?.toIso8601String(),
    };
  }
}
