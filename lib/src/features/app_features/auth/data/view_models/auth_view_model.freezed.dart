// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthViewModel {

 String get userName; String get email; bool get isAuthenticated;
/// Create a copy of AuthViewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthViewModelCopyWith<AuthViewModel> get copyWith => _$AuthViewModelCopyWithImpl<AuthViewModel>(this as AuthViewModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthViewModel&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.email, email) || other.email == email)&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated));
}


@override
int get hashCode => Object.hash(runtimeType,userName,email,isAuthenticated);

@override
String toString() {
  return 'AuthViewModel(userName: $userName, email: $email, isAuthenticated: $isAuthenticated)';
}


}

/// @nodoc
abstract mixin class $AuthViewModelCopyWith<$Res>  {
  factory $AuthViewModelCopyWith(AuthViewModel value, $Res Function(AuthViewModel) _then) = _$AuthViewModelCopyWithImpl;
@useResult
$Res call({
 String userName, String email, bool isAuthenticated
});




}
/// @nodoc
class _$AuthViewModelCopyWithImpl<$Res>
    implements $AuthViewModelCopyWith<$Res> {
  _$AuthViewModelCopyWithImpl(this._self, this._then);

  final AuthViewModel _self;
  final $Res Function(AuthViewModel) _then;

/// Create a copy of AuthViewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userName = null,Object? email = null,Object? isAuthenticated = null,}) {
  return _then(_self.copyWith(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthViewModel].
extension AuthViewModelPatterns on AuthViewModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthViewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthViewModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthViewModel value)  $default,){
final _that = this;
switch (_that) {
case _AuthViewModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthViewModel value)?  $default,){
final _that = this;
switch (_that) {
case _AuthViewModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userName,  String email,  bool isAuthenticated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthViewModel() when $default != null:
return $default(_that.userName,_that.email,_that.isAuthenticated);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userName,  String email,  bool isAuthenticated)  $default,) {final _that = this;
switch (_that) {
case _AuthViewModel():
return $default(_that.userName,_that.email,_that.isAuthenticated);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userName,  String email,  bool isAuthenticated)?  $default,) {final _that = this;
switch (_that) {
case _AuthViewModel() when $default != null:
return $default(_that.userName,_that.email,_that.isAuthenticated);case _:
  return null;

}
}

}

/// @nodoc


class _AuthViewModel implements AuthViewModel {
  const _AuthViewModel({required this.userName, required this.email, required this.isAuthenticated});
  

@override final  String userName;
@override final  String email;
@override final  bool isAuthenticated;

/// Create a copy of AuthViewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthViewModelCopyWith<_AuthViewModel> get copyWith => __$AuthViewModelCopyWithImpl<_AuthViewModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthViewModel&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.email, email) || other.email == email)&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated));
}


@override
int get hashCode => Object.hash(runtimeType,userName,email,isAuthenticated);

@override
String toString() {
  return 'AuthViewModel(userName: $userName, email: $email, isAuthenticated: $isAuthenticated)';
}


}

/// @nodoc
abstract mixin class _$AuthViewModelCopyWith<$Res> implements $AuthViewModelCopyWith<$Res> {
  factory _$AuthViewModelCopyWith(_AuthViewModel value, $Res Function(_AuthViewModel) _then) = __$AuthViewModelCopyWithImpl;
@override @useResult
$Res call({
 String userName, String email, bool isAuthenticated
});




}
/// @nodoc
class __$AuthViewModelCopyWithImpl<$Res>
    implements _$AuthViewModelCopyWith<$Res> {
  __$AuthViewModelCopyWithImpl(this._self, this._then);

  final _AuthViewModel _self;
  final $Res Function(_AuthViewModel) _then;

/// Create a copy of AuthViewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userName = null,Object? email = null,Object? isAuthenticated = null,}) {
  return _then(_AuthViewModel(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
