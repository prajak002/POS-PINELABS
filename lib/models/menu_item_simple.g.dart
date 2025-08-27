// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_simple.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MenuItemSimpleAdapter extends TypeAdapter<MenuItemSimple> {
  @override
  final int typeId = 5;

  @override
  MenuItemSimple read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MenuItemSimple(
      username: fields[0] as String,
      food: fields[1] as String,
      price: fields[2] as double,
      vendorName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MenuItemSimple obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.food)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.vendorName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemSimpleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItemSimple _$MenuItemSimpleFromJson(Map<String, dynamic> json) =>
    MenuItemSimple(
      username: json['username'] as String,
      food: json['food'] as String,
      price: (json['price'] as num).toDouble(),
      vendorName: json['vendor_name'] as String,
    );

Map<String, dynamic> _$MenuItemSimpleToJson(MenuItemSimple instance) =>
    <String, dynamic>{
      'username': instance.username,
      'food': instance.food,
      'price': instance.price,
      'vendor_name': instance.vendorName,
    };
