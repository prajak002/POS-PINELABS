import 'package:json_annotation/json_annotation.dart';

part 'sync_models.g.dart';

@JsonSerializable()
class SyncResponse {
  final bool success;
  final String message;
  final int syncedCount;

  SyncResponse({
    required this.success,
    required this.message,
    required this.syncedCount,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SyncResponseToJson(this);
}
