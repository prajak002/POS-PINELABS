import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@HiveType(typeId: 6)
@JsonSerializable()
class OrderItem {
  @HiveField(0)
  final String menuId;

  @HiveField(1)
  final String foodName;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final double totalAmount;

  OrderItem({
    required this.menuId,
    required this.foodName,
    required this.price,
    required this.quantity,
    required this.totalAmount,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@HiveType(typeId: 7)
@JsonSerializable()
class Order {
  @HiveField(0)
  final String orderId;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final List<OrderItem> items;

  @HiveField(3)
  final double totalAmount;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String status; // pending, completed, cancelled

  @HiveField(6)
  final String? cardId;

  @HiveField(7)
  final String? paymentMethod;

  @HiveField(8)
  final bool isSync;

  Order({
    required this.orderId,
    required this.username,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
    this.status = 'pending',
    this.cardId,
    this.paymentMethod,
    this.isSync = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  // Convert to sync API format
  List<Map<String, dynamic>> toSyncJson() {
    return items.map((item) => {
      'transaction_id': '${orderId}_${item.menuId}',
      'isSync': isSync,
      'timestamp': timestamp.toIso8601String(),
      'user_name': username,
      'card_id': cardId ?? '',
      'food_name': item.foodName,
      'price': item.price,
      'quantity': item.quantity,
      'totalAmount': item.totalAmount,
    }).toList();
  }

  Order copyWith({
    String? orderId,
    String? username,
    List<OrderItem>? items,
    double? totalAmount,
    DateTime? timestamp,
    String? status,
    String? cardId,
    String? paymentMethod,
    bool? isSync,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      username: username ?? this.username,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      cardId: cardId ?? this.cardId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSync: isSync ?? this.isSync,
    );
  }
}
