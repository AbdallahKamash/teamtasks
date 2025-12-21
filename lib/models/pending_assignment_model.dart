import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_assignment_model.freezed.dart';
part 'pending_assignment_model.g.dart';

@freezed
abstract class PendingAssignmentModel with _$PendingAssignmentModel {
  const factory PendingAssignmentModel({
    required String id,
    required String workspaceId,
    required String inviterName,
    required String inviterId,
    required String role,
    required String email,
    required DateTime createdAt,
    String? inviteeId,
  }) = _PendingAssignmentModel;

  factory PendingAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$PendingAssignmentModelFromJson(json);
}
