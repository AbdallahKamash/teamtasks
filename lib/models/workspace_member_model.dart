import 'package:freezed_annotation/freezed_annotation.dart';

part 'workspace_member_model.freezed.dart';
part 'workspace_member_model.g.dart';

@freezed
abstract class WorkspaceMemberModel with _$WorkspaceMemberModel {
  const factory WorkspaceMemberModel({
    required String uid,
    required String email,
    required String displayName,
    String? roleId,
    String? pfp,
    required DateTime joinedAt,
  }) = _WorkspaceMemberModel;

  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceMemberModelFromJson(json);
}
