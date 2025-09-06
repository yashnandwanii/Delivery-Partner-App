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
      id: fields[0] as String,
      userId: fields[1] as String,
      restaurantId: fields[2] as String,
      restaurantName: fields[3] as String,
      orderItems: (fields[4] as List).cast<OrderItem>(),
      orderTotal: fields[5] as double,
      deliveryFee: fields[6] as double,
      grandTotal: fields[7] as double,
      pickupLocation: fields[8] as LocationModel,
      deliveryLocation: fields[9] as LocationModel,
      orderStatus: fields[10] as String,
      paymentStatus: fields[11] as String,
      paymentMethod: fields[12] as String,
      orderDate: fields[13] as DateTime,
      estimatedDeliveryTime: fields[14] as DateTime?,
      actualDeliveryTime: fields[15] as DateTime?,
      deliveryPartnerId: fields[16] as String?,
      specialInstructions: fields[17] as String?,
      customerName: fields[18] as String,
      customerPhone: fields[19] as String,
      distance: fields[20] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryOrder obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.restaurantId)
      ..writeByte(3)
      ..write(obj.restaurantName)
      ..writeByte(4)
      ..write(obj.orderItems)
      ..writeByte(5)
      ..write(obj.orderTotal)
      ..writeByte(6)
      ..write(obj.deliveryFee)
      ..writeByte(7)
      ..write(obj.grandTotal)
      ..writeByte(8)
      ..write(obj.pickupLocation)
      ..writeByte(9)
      ..write(obj.deliveryLocation)
      ..writeByte(10)
      ..write(obj.orderStatus)
      ..writeByte(11)
      ..write(obj.paymentStatus)
      ..writeByte(12)
      ..write(obj.paymentMethod)
      ..writeByte(13)
      ..write(obj.orderDate)
      ..writeByte(14)
      ..write(obj.estimatedDeliveryTime)
      ..writeByte(15)
      ..write(obj.actualDeliveryTime)
      ..writeByte(16)
      ..write(obj.deliveryPartnerId)
      ..writeByte(17)
      ..write(obj.specialInstructions)
      ..writeByte(18)
      ..write(obj.customerName)
      ..writeByte(19)
      ..write(obj.customerPhone)
      ..writeByte(20)
      ..write(obj.distance);
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
  final int typeId = 3;

  @override
  LocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationModel(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      address: fields[2] as String,
      landmark: fields[3] as String?,
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
      ..write(obj.landmark);
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
  final int typeId = 4;

  @override
  OrderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItem(
      foodId: fields[0] as String,
      foodName: fields[1] as String,
      quantity: fields[2] as int,
      price: fields[3] as double,
      additives: (fields[4] as List).cast<String>(),
      instructions: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.foodId)
      ..writeByte(1)
      ..write(obj.foodName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.additives)
      ..writeByte(5)
      ..write(obj.instructions);
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
