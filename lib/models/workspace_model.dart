import 'package:freezed_annotation/freezed_annotation.dart';

part 'workspace_model.freezed.dart';
part 'workspace_model.g.dart';

@freezed
abstract class WorkspaceModel with _$WorkspaceModel {
  const factory WorkspaceModel({
    required String id,
    required String name,
    required String color,
    required String creatorId,
    required DateTime createdAt,
    String? description,
    String? logoUrl,
    List<String>? titles,
    Map<String, String>? scheme,
  }) = _WorkspaceModel;

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceModelFromJson(json);
}
