import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel {
  LoginRequestModel({required this.email, required this.password});

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  final String email;
  final String password;

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}
