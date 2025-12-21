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
    };
