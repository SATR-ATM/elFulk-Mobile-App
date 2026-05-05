import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_view_model.freezed.dart';

@freezed
abstract class AuthViewModel with _$AuthViewModel {
  const factory AuthViewModel({
    required String userName,
    required String email,
    required bool isAuthenticated,
  }) = _AuthViewModel;
}
