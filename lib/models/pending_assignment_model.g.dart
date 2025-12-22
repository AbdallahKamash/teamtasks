// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_assignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PendingAssignmentModel _$PendingAssignmentModelFromJson(
  Map<String, dynamic> json,
) => _PendingAssignmentModel(
  id: json['id'] as String,
  workspaceId: json['workspaceId'] as String,
  inviterName: json['inviterName'] as String,
  inviterId: json['inviterId'] as String,
  roleId: json['roleId'] as String,
  email: json['email'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  inviteeId: json['inviteeId'] as String?,
);

Map<String, dynamic> _$PendingAssignmentModelToJson(
  _PendingAssignmentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'workspaceId': instance.workspaceId,
  'inviterName': instance.inviterName,
  'inviterId': instance.inviterId,
  'roleId': instance.roleId,
  'email': instance.email,
  'createdAt': instance.createdAt.toIso8601String(),
  'inviteeId': instance.inviteeId,
};
