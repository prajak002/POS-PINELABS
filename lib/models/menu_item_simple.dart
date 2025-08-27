import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'menu_item_simple.g.dart';

// Simplified MenuItem model for API compatibility
@JsonSerializable()
@HiveType(typeId: 5) // Using typeId 5 to avoid conflicts with other models
class MenuItemSimple {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String food;

  @HiveField(2)
  final double price;

  @HiveField(3)
  @JsonKey(name: 'vendor_name')
  final String vendorName;

  MenuItemSimple({
    required this.username,
    required this.food,
    required this.price,
    required this.vendorName,
  });

  factory MenuItemSimple.fromJson(Map<String, dynamic> json) =>
      _$MenuItemSimpleFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemSimpleToJson(this);

  // For API calls
  Map<String, dynamic> toApiJson() => {
        'username': username,
        'food': food,
        'price': price,
        'vendor_name': vendorName,
      };

  @override
  String toString() => 'MenuItemSimple(food: $food, price: ₹$price, vendor: $vendorName)';
}
