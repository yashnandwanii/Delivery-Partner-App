// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_delivery_partner.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SimpleDeliveryPartnerAdapter extends TypeAdapter<SimpleDeliveryPartner> {
  @override
  final int typeId = 10;

  @override
  SimpleDeliveryPartner read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SimpleDeliveryPartner(
      id: fields[0] as String?,
      name: fields[1] as String?,
      email: fields[2] as String?,
      phone: fields[3] as String?,
      profileImage: fields[4] as String?,
      isVerified: fields[5] as bool?,
      isOnline: fields[6] as bool?,
      vehicleType: fields[7] as String?,
      vehicleNumber: fields[8] as String?,
      licenseNumber: fields[9] as String?,
      currentLocation: fields[10] as SimpleLocationModel?,
      rating: fields[11] as double?,
      totalDeliveries: fields[12] as int?,
      earnings: fields[13] as double?,
      status: fields[14] as String?,
      documents: (fields[15] as List?)?.cast<String>(),
      createdAt: fields[16] as DateTime?,
      updatedAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SimpleDeliveryPartner obj) {
    writer
      ..writeByte(18)
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
      ..write(obj.isVerified)
      ..writeByte(6)
      ..write(obj.isOnline)
      ..writeByte(7)
      ..write(obj.vehicleType)
      ..writeByte(8)
      ..write(obj.vehicleNumber)
      ..writeByte(9)
      ..write(obj.licenseNumber)
      ..writeByte(10)
      ..write(obj.currentLocation)
      ..writeByte(11)
      ..write(obj.rating)
      ..writeByte(12)
      ..write(obj.totalDeliveries)
      ..writeByte(13)
      ..write(obj.earnings)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.documents)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleDeliveryPartnerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SimpleLocationModelAdapter extends TypeAdapter<SimpleLocationModel> {
  @override
  final int typeId = 11;

  @override
  SimpleLocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SimpleLocationModel(
      latitude: fields[0] as double?,
      longitude: fields[1] as double?,
      address: fields[2] as String?,
      timestamp: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SimpleLocationModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleLocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
