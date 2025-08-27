// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MenuItemAdapter extends TypeAdapter<MenuItem> {
  @override
  final int typeId = 2;

  @override
  MenuItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MenuItem(
      menuId: fields[0] as String,
      username: fields[1] as String,
      food: fields[2] as String,
      price: fields[3] as double,
      vendorName: fields[4] as String,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MenuItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.menuId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.food)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.vendorName)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
      menuId: json['menu_id'] as String,
      username: json['username'] as String,
      food: json['food'] as String,
      price: (json['price'] as num).toDouble(),
      vendorName: json['vendor_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
      'menu_id': instance.menuId,
      'username': instance.username,
      'food': instance.food,
      'price': instance.price,
      'vendor_name': instance.vendorName,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
