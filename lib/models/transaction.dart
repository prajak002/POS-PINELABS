import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@HiveType(typeId: 3)
enum TransactionType {
  @HiveField(0)
  issue,
  
  @HiveField(1)
  topup,
  
  @HiveField(2)
  payment,
  
  @HiveField(3)
  refund,
}

@HiveType(typeId: 4)
enum TransactionStatus {
  @HiveField(0)
  pending,
  
  @HiveField(1)
  completed,
  
  @HiveField(2)
  failed,
  
  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 0)
@JsonSerializable()
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cardUid; // Changed from uid to cardUid for clarity

  @HiveField(2)
  @JsonKey(name: 'type')
  final TransactionType type; // Changed to enum

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final double? balanceAfter;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final String? billingRefNo;

  @HiveField(7)
  final TransactionStatus status; // Changed to enum

  @HiveField(8)
  final String? approvalCode;

  @HiveField(9)
  final String? transactionId;

  @HiveField(10)
  final Map<String, dynamic>? additionalData;

  Transaction({
    required this.id,
    required this.cardUid,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.status,
    this.balanceAfter,
    this.billingRefNo,
    this.approvalCode,
    this.transactionId,
    this.additionalData,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  Transaction copyWith({
    String? id,
    String? cardUid,
    TransactionType? type,
    double? amount,
    double? balanceAfter,
    DateTime? timestamp,
    String? billingRefNo,
    TransactionStatus? status,
    String? approvalCode,
    String? transactionId,
    Map<String, dynamic>? additionalData,
  }) {
    return Transaction(
      id: id ?? this.id,
      cardUid: cardUid ?? this.cardUid,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      timestamp: timestamp ?? this.timestamp,
      billingRefNo: billingRefNo ?? this.billingRefNo,
      status: status ?? this.status,
      approvalCode: approvalCode ?? this.approvalCode,
      transactionId: transactionId ?? this.transactionId,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

@HiveType(typeId: 1)
@JsonSerializable()
class CardData {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final double balance;

  @HiveField(2)
  final DateTime lastUpdated;

  CardData({
    required this.uid,
    required this.balance,
    required this.lastUpdated,
  });

  factory CardData.fromJson(Map<String, dynamic> json) =>
      _$CardDataFromJson(json);

  Map<String, dynamic> toJson() => _$CardDataToJson(this);

  CardData copyWith({
    String? uid,
    double? balance,
    DateTime? lastUpdated,
  }) {
    return CardData(
      uid: uid ?? this.uid,
      balance: balance ?? this.balance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
