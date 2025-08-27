import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'accessToken')
  final String token;
  final String message;
  final bool success;
  final User? user;

  LoginResponse({
    required this.token,
    required this.message,
    this.success = true,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class User {
  final String username;
  final String role;
  final List<String>? groups;
  final String? email;
  final String? fullName;

  User({
    required this.username,
    required this.role,
    this.groups,
    this.email,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isTopupUser => role == 'topup_user' || role == 'top_up_counter' || (groups?.contains('topup_user') ?? false) || (groups?.contains('top_up_counter') ?? false);
  bool get isStallUser => role == 'stall_user' || role == 'stall_vendor' || (groups?.contains('stall_vendor') ?? false) || (groups?.contains('stall_user') ?? false);
}
