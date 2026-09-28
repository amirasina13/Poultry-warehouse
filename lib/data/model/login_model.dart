import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginModel {
  /// The generated code assumes these values exist in JSON.
  @JsonKey(name: 'login_id')
  final int loginId;

  @JsonKey(name: 'login_username')
  final String username;

  // @JsonKey(name: 'login_password')
  // final String? password;

  @JsonKey(name: 'login_email')
  final String email;

  // @JsonKey(name: 'login_token')
  // final String token;

  @JsonKey(name: 'location_id')
  final int? locationID;

  @JsonKey(name: 'location_name')
  final String? locationName;

  @JsonKey(name: 'tray_weight')
  final double? trayWeight;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  LoginModel({
    required this.loginId,
    required this.username,
    // this.password,
    required this.email,
    // required this.token,
    this.locationID,
    this.locationName,
    this.trayWeight,
    this.createdAt,
    this.updatedAt,
  });

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}
