// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkspaceMemberModel _$WorkspaceMemberModelFromJson(
  Map<String, dynamic> json,
) => _WorkspaceMemberModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String,
  roleId: json['roleId'] as String?,
  pfp: json['pfp'] as String?,
  joinedAt: DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$WorkspaceMemberModelToJson(
  _WorkspaceMemberModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'roleId': instance.roleId,
  'pfp': instance.pfp,
  'joinedAt': instance.joinedAt.toIso8601String(),
};
