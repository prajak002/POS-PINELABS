// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncResponse _$SyncResponseFromJson(Map<String, dynamic> json) => SyncResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      syncedCount: (json['syncedCount'] as num).toInt(),
    );

Map<String, dynamic> _$SyncResponseToJson(SyncResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'syncedCount': instance.syncedCount,
    };
