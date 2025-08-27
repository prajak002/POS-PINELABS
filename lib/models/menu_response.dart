import 'package:json_annotation/json_annotation.dart';
import 'menu_item_simple.dart';

part 'menu_response.g.dart';

@JsonSerializable()
class MenuResponse {
  final bool success;
  final List<MenuItemData> data;
  final int count;

  MenuResponse({
    required this.success,
    required this.data,
    required this.count,
  });

  factory MenuResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MenuResponseToJson(this);
}

@JsonSerializable()
class MenuItemData {
  final double price;
  final String food;

  MenuItemData({
    required this.price,
    required this.food,
  });

  factory MenuItemData.fromJson(Map<String, dynamic> json) =>
      _$MenuItemDataFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemDataToJson(this);

  // Convert to MenuItemSimple with default values for missing fields
  MenuItemSimple toMenuItemSimple({
    String username = 'stall_user',
    String vendorName = 'Default Vendor',
  }) {
    return MenuItemSimple(
      username: username,
      food: food,
      price: price,
      vendorName: vendorName,
    );
  }
}
