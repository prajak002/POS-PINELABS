// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      cardUid: fields[1] as String,
      type: fields[2] as TransactionType,
      amount: fields[3] as double,
      timestamp: fields[5] as DateTime,
      status: fields[7] as TransactionStatus,
      balanceAfter: fields[4] as double?,
      billingRefNo: fields[6] as String?,
      approvalCode: fields[8] as String?,
      transactionId: fields[9] as String?,
      additionalData: (fields[10] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardUid)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.balanceAfter)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.billingRefNo)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.approvalCode)
      ..writeByte(9)
      ..write(obj.transactionId)
      ..writeByte(10)
      ..write(obj.additionalData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CardDataAdapter extends TypeAdapter<CardData> {
  @override
  final int typeId = 1;

  @override
  CardData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardData(
      uid: fields[0] as String,
      balance: fields[1] as double,
      lastUpdated: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CardData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.balance)
      ..writeByte(2)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 3;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.issue;
      case 1:
        return TransactionType.topup;
      case 2:
        return TransactionType.payment;
      case 3:
        return TransactionType.refund;
      default:
        return TransactionType.issue;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.issue:
        writer.writeByte(0);
        break;
      case TransactionType.topup:
        writer.writeByte(1);
        break;
      case TransactionType.payment:
        writer.writeByte(2);
        break;
      case TransactionType.refund:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionStatusAdapter extends TypeAdapter<TransactionStatus> {
  @override
  final int typeId = 4;

  @override
  TransactionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionStatus.pending;
      case 1:
        return TransactionStatus.completed;
      case 2:
        return TransactionStatus.failed;
      case 3:
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionStatus obj) {
    switch (obj) {
      case TransactionStatus.pending:
        writer.writeByte(0);
        break;
      case TransactionStatus.completed:
        writer.writeByte(1);
        break;
      case TransactionStatus.failed:
        writer.writeByte(2);
        break;
      case TransactionStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      id: json['id'] as String,
      cardUid: json['cardUid'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      billingRefNo: json['billingRefNo'] as String?,
      approvalCode: json['approvalCode'] as String?,
      transactionId: json['transactionId'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cardUid': instance.cardUid,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'balanceAfter': instance.balanceAfter,
      'timestamp': instance.timestamp.toIso8601String(),
      'billingRefNo': instance.billingRefNo,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'approvalCode': instance.approvalCode,
      'transactionId': instance.transactionId,
      'additionalData': instance.additionalData,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.issue: 'issue',
  TransactionType.topup: 'topup',
  TransactionType.payment: 'payment',
  TransactionType.refund: 'refund',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.completed: 'completed',
  TransactionStatus.failed: 'failed',
  TransactionStatus.cancelled: 'cancelled',
};

CardData _$CardDataFromJson(Map<String, dynamic> json) => CardData(
      uid: json['uid'] as String,
      balance: (json['balance'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$CardDataToJson(CardData instance) => <String, dynamic>{
      'uid': instance.uid,
      'balance': instance.balance,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
