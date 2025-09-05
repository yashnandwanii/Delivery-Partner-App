// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryOrderAdapter extends TypeAdapter<DeliveryOrder> {
  @override
  final int typeId = 2;

  @override
  DeliveryOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeliveryOrder(
      id: fields[0] as String?,
      customerId: fields[1] as String?,
      restaurantId: fields[2] as String?,
      restaurantName: fields[3] as String?,
      customerName: fields[4] as String?,
      customerPhone: fields[5] as String?,
      pickupLocation: fields[6] as LocationModel?,
      deliveryLocation: fields[7] as LocationModel?,
      deliveryAddress: fields[8] as String?,
      items: (fields[9] as List?)?.cast<OrderItem>(),
      totalAmount: fields[10] as double?,
      deliveryFee: fields[11] as double?,
      status: fields[12] as String?,
      orderTime: fields[13] as DateTime?,
      acceptedTime: fields[14] as DateTime?,
      pickedUpTime: fields[15] as DateTime?,
      deliveredTime: fields[16] as DateTime?,
      specialInstructions: fields[17] as String?,
      paymentMethod: fields[18] as String?,
      paymentStatus: fields[19] as String?,
      distance: fields[20] as double?,
      estimatedTime: fields[21] as int?,
      otp: fields[22] as String?,
      images: (fields[23] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryOrder obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.restaurantId)
      ..writeByte(3)
      ..write(obj.restaurantName)
      ..writeByte(4)
      ..write(obj.customerName)
      ..writeByte(5)
      ..write(obj.customerPhone)
      ..writeByte(6)
      ..write(obj.pickupLocation)
      ..writeByte(7)
      ..write(obj.deliveryLocation)
      ..writeByte(8)
      ..write(obj.deliveryAddress)
      ..writeByte(9)
      ..write(obj.items)
      ..writeByte(10)
      ..write(obj.totalAmount)
      ..writeByte(11)
      ..write(obj.deliveryFee)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.orderTime)
      ..writeByte(14)
      ..write(obj.acceptedTime)
      ..writeByte(15)
      ..write(obj.pickedUpTime)
      ..writeByte(16)
      ..write(obj.deliveredTime)
      ..writeByte(17)
      ..write(obj.specialInstructions)
      ..writeByte(18)
      ..write(obj.paymentMethod)
      ..writeByte(19)
      ..write(obj.paymentStatus)
      ..writeByte(20)
      ..write(obj.distance)
      ..writeByte(21)
      ..write(obj.estimatedTime)
      ..writeByte(22)
      ..write(obj.otp)
      ..writeByte(23)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationModelAdapter extends TypeAdapter<LocationModel> {
  @override
  final int typeId = 6;

  @override
  LocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationModel(
      latitude: fields[0] as double?,
      longitude: fields[1] as double?,
      address: fields[2] as String?,
      timestamp: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationModel obj) {
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
      other is LocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final int typeId = 7;

  @override
  OrderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItem(
      id: fields[0] as String?,
      name: fields[1] as String?,
      quantity: fields[2] as int?,
      price: fields[3] as double?,
      image: fields[4] as String?,
      addons: (fields[5] as List?)?.cast<String>(),
      specialInstructions: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.addons)
      ..writeByte(6)
      ..write(obj.specialInstructions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
