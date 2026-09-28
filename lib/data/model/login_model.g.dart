// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginModel _$LoginModelFromJson(Map<String, dynamic> json) => LoginModel(
      loginId: (json['login_id'] as num).toInt(),
      username: json['login_username'] as String,
      email: json['login_email'] as String,
      locationID: (json['location_id'] as num?)?.toInt(),
      locationName: json['location_name'] as String?,
      trayWeight: (json['tray_weight'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$LoginModelToJson(LoginModel instance) =>
    <String, dynamic>{
      'login_id': instance.loginId,
      'login_username': instance.username,
      'login_email': instance.email,
      'location_id': instance.locationID,
      'location_name': instance.locationName,
      'tray_weight': instance.trayWeight,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
