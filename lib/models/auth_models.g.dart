// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      token: json['accessToken'] as String,
      message: json['message'] as String,
      success: json['success'] as bool? ?? true,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.token,
      'message': instance.message,
      'success': instance.success,
      'user': instance.user,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      username: json['username'] as String,
      role: json['role'] as String,
      groups:
          (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList(),
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'username': instance.username,
      'role': instance.role,
      'groups': instance.groups,
      'email': instance.email,
      'fullName': instance.fullName,
    };
