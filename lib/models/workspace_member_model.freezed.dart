// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkspaceMemberModel {

 String get uid; String get email; String get displayName; String? get roleId; String? get pfp; DateTime get joinedAt;
/// Create a copy of WorkspaceMemberModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceMemberModelCopyWith<WorkspaceMemberModel> get copyWith => _$WorkspaceMemberModelCopyWithImpl<WorkspaceMemberModel>(this as WorkspaceMemberModel, _$identity);

  /// Serializes this WorkspaceMemberModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceMemberModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.pfp, pfp) || other.pfp == pfp)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,displayName,roleId,pfp,joinedAt);

@override
String toString() {
  return 'WorkspaceMemberModel(uid: $uid, email: $email, displayName: $displayName, roleId: $roleId, pfp: $pfp, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $WorkspaceMemberModelCopyWith<$Res>  {
  factory $WorkspaceMemberModelCopyWith(WorkspaceMemberModel value, $Res Function(WorkspaceMemberModel) _then) = _$WorkspaceMemberModelCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String displayName, String? roleId, String? pfp, DateTime joinedAt
});




}
/// @nodoc
class _$WorkspaceMemberModelCopyWithImpl<$Res>
    implements $WorkspaceMemberModelCopyWith<$Res> {
  _$WorkspaceMemberModelCopyWithImpl(this._self, this._then);

  final WorkspaceMemberModel _self;
  final $Res Function(WorkspaceMemberModel) _then;

/// Create a copy of WorkspaceMemberModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? displayName = null,Object? roleId = freezed,Object? pfp = freezed,Object? joinedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,roleId: freezed == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String?,pfp: freezed == pfp ? _self.pfp : pfp // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceMemberModel].
extension WorkspaceMemberModelPatterns on WorkspaceMemberModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceMemberModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceMemberModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceMemberModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceMemberModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceMemberModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceMemberModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String email,  String displayName,  String? roleId,  String? pfp,  DateTime joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceMemberModel() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.roleId,_that.pfp,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String email,  String displayName,  String? roleId,  String? pfp,  DateTime joinedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceMemberModel():
return $default(_that.uid,_that.email,_that.displayName,_that.roleId,_that.pfp,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String email,  String displayName,  String? roleId,  String? pfp,  DateTime joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceMemberModel() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.roleId,_that.pfp,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkspaceMemberModel implements WorkspaceMemberModel {
  const _WorkspaceMemberModel({required this.uid, required this.email, required this.displayName, this.roleId, this.pfp, required this.joinedAt});
  factory _WorkspaceMemberModel.fromJson(Map<String, dynamic> json) => _$WorkspaceMemberModelFromJson(json);

@override final  String uid;
@override final  String email;
@override final  String displayName;
@override final  String? roleId;
@override final  String? pfp;
@override final  DateTime joinedAt;

/// Create a copy of WorkspaceMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceMemberModelCopyWith<_WorkspaceMemberModel> get copyWith => __$WorkspaceMemberModelCopyWithImpl<_WorkspaceMemberModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkspaceMemberModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceMemberModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.pfp, pfp) || other.pfp == pfp)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,displayName,roleId,pfp,joinedAt);

@override
String toString() {
  return 'WorkspaceMemberModel(uid: $uid, email: $email, displayName: $displayName, roleId: $roleId, pfp: $pfp, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceMemberModelCopyWith<$Res> implements $WorkspaceMemberModelCopyWith<$Res> {
  factory _$WorkspaceMemberModelCopyWith(_WorkspaceMemberModel value, $Res Function(_WorkspaceMemberModel) _then) = __$WorkspaceMemberModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String displayName, String? roleId, String? pfp, DateTime joinedAt
});




}
/// @nodoc
class __$WorkspaceMemberModelCopyWithImpl<$Res>
    implements _$WorkspaceMemberModelCopyWith<$Res> {
  __$WorkspaceMemberModelCopyWithImpl(this._self, this._then);

  final _WorkspaceMemberModel _self;
  final $Res Function(_WorkspaceMemberModel) _then;

/// Create a copy of WorkspaceMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? displayName = null,Object? roleId = freezed,Object? pfp = freezed,Object? joinedAt = null,}) {
  return _then(_WorkspaceMemberModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,roleId: freezed == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String?,pfp: freezed == pfp ? _self.pfp : pfp // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
