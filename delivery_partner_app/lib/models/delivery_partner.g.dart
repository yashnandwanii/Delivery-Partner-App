// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_partner.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryPartnerAdapter extends TypeAdapter<DeliveryPartner> {
  @override
  final int typeId = 0;

  @override
  DeliveryPartner read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeliveryPartner(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      profileImage: fields[4] as String,
      dateOfBirth: fields[5] as DateTime,
      gender: fields[6] as String,
      address: fields[7] as Address,
      vehicle: fields[8] as Vehicle,
      documents: fields[9] as Documents,
      verification: fields[10] as Verification,
      status: fields[11] as String,
      availability: fields[12] as Availability,
      currentLocation: fields[13] as CurrentLocation?,
      metrics: fields[14] as Metrics,
      fcmToken: fields[15] as String,
      emergencyContact: fields[16] as EmergencyContact,
      settings: fields[17] as Settings,
      createdAt: fields[18] as DateTime,
      updatedAt: fields[19] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryPartner obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.profileImage)
      ..writeByte(5)
      ..write(obj.dateOfBirth)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.vehicle)
      ..writeByte(9)
      ..write(obj.documents)
      ..writeByte(10)
      ..write(obj.verification)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.availability)
      ..writeByte(13)
      ..write(obj.currentLocation)
      ..writeByte(14)
      ..write(obj.metrics)
      ..writeByte(15)
      ..write(obj.fcmToken)
      ..writeByte(16)
      ..write(obj.emergencyContact)
      ..writeByte(17)
      ..write(obj.settings)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryPartnerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AddressAdapter extends TypeAdapter<Address> {
  @override
  final int typeId = 1;

  @override
  Address read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Address(
      street: fields[0] as String,
      city: fields[1] as String,
      state: fields[2] as String,
      pincode: fields[3] as String,
      coordinates: fields[4] as Coordinates,
    );
  }

  @override
  void write(BinaryWriter writer, Address obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.street)
      ..writeByte(1)
      ..write(obj.city)
      ..writeByte(2)
      ..write(obj.state)
      ..writeByte(3)
      ..write(obj.pincode)
      ..writeByte(4)
      ..write(obj.coordinates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CoordinatesAdapter extends TypeAdapter<Coordinates> {
  @override
  final int typeId = 2;

  @override
  Coordinates read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Coordinates(
      lat: fields[0] as double,
      lng: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Coordinates obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lng);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoordinatesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 3;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      type: fields[0] as String,
      registrationNumber: fields[1] as String,
      model: fields[2] as String,
      color: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.registrationNumber)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentsAdapter extends TypeAdapter<Documents> {
  @override
  final int typeId = 4;

  @override
  Documents read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Documents(
      aadharCard: fields[0] as AadharCard,
      panCard: fields[1] as PanCard,
      drivingLicense: fields[2] as DrivingLicense,
      vehicleRC: fields[3] as VehicleRC,
      bankDetails: fields[4] as BankDetails,
    );
  }

  @override
  void write(BinaryWriter writer, Documents obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.aadharCard)
      ..writeByte(1)
      ..write(obj.panCard)
      ..writeByte(2)
      ..write(obj.drivingLicense)
      ..writeByte(3)
      ..write(obj.vehicleRC)
      ..writeByte(4)
      ..write(obj.bankDetails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AadharCardAdapter extends TypeAdapter<AadharCard> {
  @override
  final int typeId = 5;

  @override
  AadharCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AadharCard(
      number: fields[0] as String,
      imageUrl: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AadharCard obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AadharCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PanCardAdapter extends TypeAdapter<PanCard> {
  @override
  final int typeId = 6;

  @override
  PanCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PanCard(
      number: fields[0] as String,
      imageUrl: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PanCard obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PanCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DrivingLicenseAdapter extends TypeAdapter<DrivingLicense> {
  @override
  final int typeId = 7;

  @override
  DrivingLicense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrivingLicense(
      number: fields[0] as String,
      imageUrl: fields[1] as String,
      expiryDate: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DrivingLicense obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.expiryDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrivingLicenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VehicleRCAdapter extends TypeAdapter<VehicleRC> {
  @override
  final int typeId = 8;

  @override
  VehicleRC read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VehicleRC(
      number: fields[0] as String,
      imageUrl: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VehicleRC obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleRCAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BankDetailsAdapter extends TypeAdapter<BankDetails> {
  @override
  final int typeId = 9;

  @override
  BankDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BankDetails(
      accountNumber: fields[0] as String,
      ifscCode: fields[1] as String,
      accountHolderName: fields[2] as String,
      bankName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BankDetails obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.accountNumber)
      ..writeByte(1)
      ..write(obj.ifscCode)
      ..writeByte(2)
      ..write(obj.accountHolderName)
      ..writeByte(3)
      ..write(obj.bankName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VerificationAdapter extends TypeAdapter<Verification> {
  @override
  final int typeId = 10;

  @override
  Verification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Verification(
      email: fields[0] as bool,
      phone: fields[1] as bool,
      documents: fields[2] as bool,
      background: fields[3] as bool,
      overall: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Verification obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.documents)
      ..writeByte(3)
      ..write(obj.background)
      ..writeByte(4)
      ..write(obj.overall);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AvailabilityAdapter extends TypeAdapter<Availability> {
  @override
  final int typeId = 11;

  @override
  Availability read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Availability(
      isOnline: fields[0] as bool,
      isAvailable: fields[1] as bool,
      lastSeen: fields[2] as DateTime,
      workingHours: fields[3] as WorkingHours,
    );
  }

  @override
  void write(BinaryWriter writer, Availability obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.isOnline)
      ..writeByte(1)
      ..write(obj.isAvailable)
      ..writeByte(2)
      ..write(obj.lastSeen)
      ..writeByte(3)
      ..write(obj.workingHours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailabilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkingHoursAdapter extends TypeAdapter<WorkingHours> {
  @override
  final int typeId = 12;

  @override
  WorkingHours read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkingHours(
      start: fields[0] as String,
      end: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WorkingHours obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkingHoursAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CurrentLocationAdapter extends TypeAdapter<CurrentLocation> {
  @override
  final int typeId = 13;

  @override
  CurrentLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentLocation(
      lat: fields[0] as double,
      lng: fields[1] as double,
      lastUpdated: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CurrentLocation obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lng)
      ..writeByte(2)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MetricsAdapter extends TypeAdapter<Metrics> {
  @override
  final int typeId = 14;

  @override
  Metrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Metrics(
      totalOrders: fields[0] as int,
      completedOrders: fields[1] as int,
      cancelledOrders: fields[2] as int,
      rating: fields[3] as double,
      totalRatings: fields[4] as int,
      onTimeDeliveries: fields[5] as int,
      averageDeliveryTime: fields[6] as double,
      totalEarnings: fields[7] as double,
      thisMonthEarnings: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Metrics obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.totalOrders)
      ..writeByte(1)
      ..write(obj.completedOrders)
      ..writeByte(2)
      ..write(obj.cancelledOrders)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.totalRatings)
      ..writeByte(5)
      ..write(obj.onTimeDeliveries)
      ..writeByte(6)
      ..write(obj.averageDeliveryTime)
      ..writeByte(7)
      ..write(obj.totalEarnings)
      ..writeByte(8)
      ..write(obj.thisMonthEarnings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmergencyContactAdapter extends TypeAdapter<EmergencyContact> {
  @override
  final int typeId = 15;

  @override
  EmergencyContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmergencyContact(
      name: fields[0] as String,
      phone: fields[1] as String,
      relationship: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EmergencyContact obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.relationship);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 16;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      notifications: fields[0] as NotificationSettings,
      privacy: fields[1] as PrivacySettings,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.notifications)
      ..writeByte(1)
      ..write(obj.privacy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationSettingsAdapter extends TypeAdapter<NotificationSettings> {
  @override
  final int typeId = 17;

  @override
  NotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettings(
      orderAlerts: fields[0] as bool,
      promotions: fields[1] as bool,
      accountUpdates: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.orderAlerts)
      ..writeByte(1)
      ..write(obj.promotions)
      ..writeByte(2)
      ..write(obj.accountUpdates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrivacySettingsAdapter extends TypeAdapter<PrivacySettings> {
  @override
  final int typeId = 18;

  @override
  PrivacySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrivacySettings(
      shareLocation: fields[0] as bool,
      profileVisibility: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PrivacySettings obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.shareLocation)
      ..writeByte(1)
      ..write(obj.profileVisibility);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacySettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
