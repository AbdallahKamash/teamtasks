// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_assignment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PendingAssignmentModel {

 String get id; String get workspaceId; String get inviterName; String get inviterId; String get role; String get email; DateTime get createdAt; String? get inviteeId;
/// Create a copy of PendingAssignmentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingAssignmentModelCopyWith<PendingAssignmentModel> get copyWith => _$PendingAssignmentModelCopyWithImpl<PendingAssignmentModel>(this as PendingAssignmentModel, _$identity);

  /// Serializes this PendingAssignmentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingAssignmentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId)&&(identical(other.inviterName, inviterName) || other.inviterName == inviterName)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.role, role) || other.role == role)&&(identical(other.email, email) || other.email == email)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.inviteeId, inviteeId) || other.inviteeId == inviteeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workspaceId,inviterName,inviterId,role,email,createdAt,inviteeId);

@override
String toString() {
  return 'PendingAssignmentModel(id: $id, workspaceId: $workspaceId, inviterName: $inviterName, inviterId: $inviterId, role: $role, email: $email, createdAt: $createdAt, inviteeId: $inviteeId)';
}


}

/// @nodoc
abstract mixin class $PendingAssignmentModelCopyWith<$Res>  {
  factory $PendingAssignmentModelCopyWith(PendingAssignmentModel value, $Res Function(PendingAssignmentModel) _then) = _$PendingAssignmentModelCopyWithImpl;
@useResult
$Res call({
 String id, String workspaceId, String inviterName, String inviterId, String role, String email, DateTime createdAt, String? inviteeId
});




}
/// @nodoc
class _$PendingAssignmentModelCopyWithImpl<$Res>
    implements $PendingAssignmentModelCopyWith<$Res> {
  _$PendingAssignmentModelCopyWithImpl(this._self, this._then);

  final PendingAssignmentModel _self;
  final $Res Function(PendingAssignmentModel) _then;

/// Create a copy of PendingAssignmentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workspaceId = null,Object? inviterName = null,Object? inviterId = null,Object? role = null,Object? email = null,Object? createdAt = null,Object? inviteeId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workspaceId: null == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as String,inviterName: null == inviterName ? _self.inviterName : inviterName // ignore: cast_nullable_to_non_nullable
as String,inviterId: null == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,inviteeId: freezed == inviteeId ? _self.inviteeId : inviteeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingAssignmentModel].
extension PendingAssignmentModelPatterns on PendingAssignmentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingAssignmentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingAssignmentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingAssignmentModel value)  $default,){
final _that = this;
switch (_that) {
case _PendingAssignmentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingAssignmentModel value)?  $default,){
final _that = this;
switch (_that) {
case _PendingAssignmentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workspaceId,  String inviterName,  String inviterId,  String role,  String email,  DateTime createdAt,  String? inviteeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingAssignmentModel() when $default != null:
return $default(_that.id,_that.workspaceId,_that.inviterName,_that.inviterId,_that.role,_that.email,_that.createdAt,_that.inviteeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workspaceId,  String inviterName,  String inviterId,  String role,  String email,  DateTime createdAt,  String? inviteeId)  $default,) {final _that = this;
switch (_that) {
case _PendingAssignmentModel():
return $default(_that.id,_that.workspaceId,_that.inviterName,_that.inviterId,_that.role,_that.email,_that.createdAt,_that.inviteeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workspaceId,  String inviterName,  String inviterId,  String role,  String email,  DateTime createdAt,  String? inviteeId)?  $default,) {final _that = this;
switch (_that) {
case _PendingAssignmentModel() when $default != null:
return $default(_that.id,_that.workspaceId,_that.inviterName,_that.inviterId,_that.role,_that.email,_that.createdAt,_that.inviteeId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingAssignmentModel implements PendingAssignmentModel {
  const _PendingAssignmentModel({required this.id, required this.workspaceId, required this.inviterName, required this.inviterId, required this.role, required this.email, required this.createdAt, this.inviteeId});
  factory _PendingAssignmentModel.fromJson(Map<String, dynamic> json) => _$PendingAssignmentModelFromJson(json);

@override final  String id;
@override final  String workspaceId;
@override final  String inviterName;
@override final  String inviterId;
@override final  String role;
@override final  String email;
@override final  DateTime createdAt;
@override final  String? inviteeId;

/// Create a copy of PendingAssignmentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingAssignmentModelCopyWith<_PendingAssignmentModel> get copyWith => __$PendingAssignmentModelCopyWithImpl<_PendingAssignmentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingAssignmentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingAssignmentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId)&&(identical(other.inviterName, inviterName) || other.inviterName == inviterName)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.role, role) || other.role == role)&&(identical(other.email, email) || other.email == email)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.inviteeId, inviteeId) || other.inviteeId == inviteeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workspaceId,inviterName,inviterId,role,email,createdAt,inviteeId);

@override
String toString() {
  return 'PendingAssignmentModel(id: $id, workspaceId: $workspaceId, inviterName: $inviterName, inviterId: $inviterId, role: $role, email: $email, createdAt: $createdAt, inviteeId: $inviteeId)';
}


}

/// @nodoc
abstract mixin class _$PendingAssignmentModelCopyWith<$Res> implements $PendingAssignmentModelCopyWith<$Res> {
  factory _$PendingAssignmentModelCopyWith(_PendingAssignmentModel value, $Res Function(_PendingAssignmentModel) _then) = __$PendingAssignmentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String workspaceId, String inviterName, String inviterId, String role, String email, DateTime createdAt, String? inviteeId
});




}
/// @nodoc
class __$PendingAssignmentModelCopyWithImpl<$Res>
    implements _$PendingAssignmentModelCopyWith<$Res> {
  __$PendingAssignmentModelCopyWithImpl(this._self, this._then);

  final _PendingAssignmentModel _self;
  final $Res Function(_PendingAssignmentModel) _then;

/// Create a copy of PendingAssignmentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workspaceId = null,Object? inviterName = null,Object? inviterId = null,Object? role = null,Object? email = null,Object? createdAt = null,Object? inviteeId = freezed,}) {
  return _then(_PendingAssignmentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workspaceId: null == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as String,inviterName: null == inviterName ? _self.inviterName : inviterName // ignore: cast_nullable_to_non_nullable
as String,inviterId: null == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,inviteeId: freezed == inviteeId ? _self.inviteeId : inviteeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
