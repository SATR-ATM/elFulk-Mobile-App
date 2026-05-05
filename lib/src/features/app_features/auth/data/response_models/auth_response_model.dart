import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  AuthResponseModel({
    required this.token,
    required this.userName,
    required this.email,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  final String token;
  final String userName;
  final String email;

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
