// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkspaceModel _$WorkspaceModelFromJson(Map<String, dynamic> json) =>
    _WorkspaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      creatorId: json['creatorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      roles: (json['roles'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      scheme: (json['scheme'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      admins:
          (json['admins'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WorkspaceModelToJson(_WorkspaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'creatorId': instance.creatorId,
      'createdAt': instance.createdAt.toIso8601String(),
      'description': instance.description,
      'logoUrl': instance.logoUrl,
      'roles': instance.roles,
      'scheme': instance.scheme,
      'admins': instance.admins,
    };
