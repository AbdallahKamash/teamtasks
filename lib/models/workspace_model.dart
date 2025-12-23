import 'package:freezed_annotation/freezed_annotation.dart';

part 'workspace_model.freezed.dart';
part 'workspace_model.g.dart';

@freezed
abstract class WorkspaceModel with _$WorkspaceModel {
  const factory WorkspaceModel({
    required String id,
    required String name,
    required String color,
    required DateTime createdAt,
    String? description,
    String? logoUrl,
    Map<String, String>? roles,
    Map<String, String>? scheme,
    @Default([]) List<String> admins,
  }) = _WorkspaceModel;

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceModelFromJson(json);
}
