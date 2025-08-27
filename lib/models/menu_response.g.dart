// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuResponse _$MenuResponseFromJson(Map<String, dynamic> json) => MenuResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => MenuItemData.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$MenuResponseToJson(MenuResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'count': instance.count,
    };

MenuItemData _$MenuItemDataFromJson(Map<String, dynamic> json) => MenuItemData(
      price: (json['price'] as num).toDouble(),
      food: json['food'] as String,
    );

Map<String, dynamic> _$MenuItemDataToJson(MenuItemData instance) =>
    <String, dynamic>{
      'price': instance.price,
      'food': instance.food,
    };
