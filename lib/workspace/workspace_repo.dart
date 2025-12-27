import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/workspace_model.dart';
import '../models/user_model.dart';
import '../models/pending_assignment_model.dart';
import '../models/workspace_member_model.dart';
import '../models/task_model.dart';
import '../models/notification_model.dart';

class WorkspaceRepo {
  final FirebaseFirestore _firestore;

  WorkspaceRepo(this._firestore);

  Stream<List<WorkspaceModel>> getWorkspacesStream(String userId) {
    return _firestore
        .collection('users_workspaces')
        .doc(userId)
        .snapshots()
        .switchMap((userDoc) {
          final data = userDoc.data();
          if (data == null) {
            return Stream.value([]);
          }

          final List<String> workspaceIds = [];

          if (data['workspaces'] != null) {
            final List<dynamic> workspacesList = data['workspaces'];
            for (final w in workspacesList) {
              if (w is Map && w['workspaceId'] != null) {
                workspaceIds.add(w['workspaceId'] as String);
              }
            }
          } else if (data['workspaceIds'] != null) {
            workspaceIds.addAll(List<String>.from(data['workspaceIds']));
          }

          if (workspaceIds.isEmpty) {
            return Stream.value([]);
          }

          return _firestore
              .collection('workspaces')
              .where(FieldPath.documentId, whereIn: workspaceIds)
              .snapshots()
              .map((snapshot) {
                final workspaces = snapshot.docs
                    .map(
                      (doc) => WorkspaceModel.fromJson({
                        ...doc.data(),
                        'id': doc.id,
                      }),
                    )
                    .toList();

                workspaces.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return workspaces;
              });
        });
  }

  Future<String> createWorkspace(
    WorkspaceModel workspace,
    String creatorId,
    String creatorName,
    String creatorEmail,
  ) async {
    final adminRoleId = DateTime.now().microsecondsSinceEpoch.toString();
    final defaultRoles = {adminRoleId: 'Admin'};
    final defaultPermissions = {
      adminRoleId: {
        'people_delete': true,
        'people_add': true,
        'roles_add': true,
        'messages_edit': true,
        'tasks_add': true,
        'workspace_edit': true,
        'tasks_delete': true,
        'workspace_delete': true,
        'messages_delete': true,
        'roles_delete': true,
        'tasks_edit': true,
        'roles_edit': true,
        'people_edit': true,
        'messages_add': true,
      },
    };

    final workspaceRef = _firestore.collection('workspaces').doc();
    final workspaceWithId = workspace.copyWith(
      id: workspaceRef.id,
      roles: defaultRoles,
    );

    await workspaceRef.set(workspaceWithId.toJson());

    await workspaceRef.update({'rolePermissions': defaultPermissions});

    await _firestore.collection('users_workspaces').doc(creatorId).set({
      'workspaces': FieldValue.arrayUnion([
        {'workspaceId': workspaceRef.id},
      ]),
    }, SetOptions(merge: true));

    final member = WorkspaceMemberModel(
      uid: creatorId,
      email: creatorEmail,
      displayName: creatorName,
      joinedAt: DateTime.now(),
      roleId: adminRoleId,
    );

    await workspaceRef
        .collection('members')
        .doc(creatorId)
        .set(member.toJson());

    return workspaceRef.id;
  }

  Future<void> updateWorkspace(WorkspaceModel workspace) async {
    await _firestore
        .collection('workspaces')
        .doc(workspace.id)
        .update(workspace.toJson());
  }

  Future<Map<String, dynamic>> getRolePermissions(String workspaceId) async {
    final doc = await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .get();
    if (!doc.exists) return {};
    final data = doc.data();
    if (data == null) return {};
    final perms = data['rolePermissions'] ?? data['permissions'];
    if (perms is Map<String, dynamic>) return perms;
    return {};
  }

  /// Stream version of getRolePermissions for real-time updates
  Stream<Map<String, dynamic>> getRolePermissionsStream(String workspaceId) {
    return _firestore.collection('workspaces').doc(workspaceId).snapshots().map(
      (doc) {
        if (!doc.exists) return {};
        final data = doc.data();
        if (data == null) return {};
        final perms = data['rolePermissions'] ?? data['permissions'];
        if (perms is Map<String, dynamic>) return perms;
        return {};
      },
    );
  }

  Future<void> updateRolePermissions(
    String workspaceId,
    Map<String, dynamic> perms,
  ) async {
    await _firestore.collection('workspaces').doc(workspaceId).update({
      'rolePermissions': perms,
    });
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;

    final data = doc.data();
    return UserModel.fromJson({...data, 'uid': doc.id});
  }

  Future<void> addPendingAssignment(PendingAssignmentModel assignment) async {
    final docRef = _firestore.collection('pending_assignments').doc();
    final assignmentWithId = assignment.copyWith(id: docRef.id);
    await docRef.set(assignmentWithId.toJson());
  }

  Future<bool> isUserPending(String workspaceId, String email) async {
    final snapshot = await _firestore
        .collection('pending_assignments')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<int> getPendingAssignmentsCountForRole(
    String workspaceId,
    String roleId,
  ) async {
    final snapshot = await _firestore
        .collection('pending_assignments')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('roleId', isEqualTo: roleId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> getActiveMembersCountForRole(
    String workspaceId,
    String roleId,
  ) async {
    final snapshot = await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('members')
        .where('roleId', isEqualTo: roleId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<void> deleteWorkspace(String workspaceId) async {
    final membersSnapshot = await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('members')
        .get();

    for (final memberDoc in membersSnapshot.docs) {
      final memberId = memberDoc.id;
      final userWorkspacesRef = _firestore
          .collection('users_workspaces')
          .doc(memberId);
      final userWorkspacesDoc = await userWorkspacesRef.get();

      if (userWorkspacesDoc.exists) {
        final data = userWorkspacesDoc.data();
        if (data != null && data['workspaces'] != null) {
          final List<dynamic> workspaces = List.from(data['workspaces']);
          workspaces.removeWhere((w) => w['workspaceId'] == workspaceId);
          await userWorkspacesRef.update({'workspaces': workspaces});
        }
      }

      await memberDoc.reference.delete();
    }

    final pendingQuery = await _firestore
        .collection('pending_assignments')
        .where('workspaceId', isEqualTo: workspaceId)
        .get();

    for (final doc in pendingQuery.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('workspaces').doc(workspaceId).delete();
  }

  Stream<List<PendingAssignmentModel>> getPendingAssignmentsStream(
    String email,
  ) {
    return _firestore
        .collection('pending_assignments')
        .where('email', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PendingAssignmentModel.fromJson(doc.data()))
              .toList();
        });
  }

  Future<WorkspaceModel?> getWorkspaceById(String id) async {
    final doc = await _firestore.collection('workspaces').doc(id).get();
    if (!doc.exists) return null;
    return WorkspaceModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> rejectAssignment(String assignmentId) async {
    await _firestore
        .collection('pending_assignments')
        .doc(assignmentId)
        .delete();
  }

  Future<void> acceptAssignment(
    PendingAssignmentModel assignment,
    String userId,
    String? displayName,
    String? email,
  ) async {
    final member = WorkspaceMemberModel(
      uid: userId,
      email: email ?? assignment.email,
      displayName: displayName ?? 'User',
      joinedAt: DateTime.now(),
      roleId: assignment.roleId,
    );

    await _firestore
        .collection('workspaces')
        .doc(assignment.workspaceId)
        .collection('members')
        .doc(userId)
        .set(member.toJson());

    await _firestore.collection('users_workspaces').doc(userId).set({
      'workspaces': FieldValue.arrayUnion([
        {'workspaceId': assignment.workspaceId},
      ]),
    }, SetOptions(merge: true));

    await rejectAssignment(assignment.id);
  }

  Stream<List<WorkspaceMemberModel>> getWorkspaceMembersStream(
    String workspaceId,
  ) {
    return _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('members')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WorkspaceMemberModel.fromJson(doc.data()))
              .toList();
        });
  }

  Future<List<WorkspaceMemberModel>> getWorkspaceMembers(
    String workspaceId,
  ) async {
    final snapshot = await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('members')
        .get();

    return snapshot.docs
        .map((doc) => WorkspaceMemberModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> updateMemberRole(
    String workspaceId,
    String memberId,
    String? roleId,
  ) async {
    await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('members')
        .doc(memberId)
        .update({'roleId': roleId});
  }

  Future<void> removeMemberFromWorkspace(
    String workspaceId,
    String memberId,
  ) async {
    await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('members')
        .doc(memberId)
        .delete();

    final userWorkspacesRef = _firestore
        .collection('users_workspaces')
        .doc(memberId);
    final doc = await userWorkspacesRef.get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['workspaces'] != null) {
        final List<dynamic> workspaces = List.from(data['workspaces']);
        workspaces.removeWhere((w) => w['workspaceId'] == workspaceId);
        await userWorkspacesRef.update({'workspaces': workspaces});
      }
    }
  }

  Future<void> addMemberToWorkspace(
    String workspaceId,
    WorkspaceMemberModel member,
  ) async {
    await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('members')
        .doc(member.uid)
        .set(member.toJson());

    await _firestore.collection('users_workspaces').doc(member.uid).set({
      'workspaces': FieldValue.arrayUnion([
        {'workspaceId': workspaceId},
      ]),
    }, SetOptions(merge: true));
  }

  // Tasks
  Future<String> createTask(Map<String, dynamic> data) async {
    final docRef = _firestore.collection('tasks').doc();
    final taskWithId = {
      ...data,
      'id': docRef.id,
      'workerId': data['assigneeId'],
      'createdAt': DateTime.now().toIso8601String(),
    };
    await docRef.set(taskWithId);

    // Trigger notification to assignee
    if (data['assigneeId'] != null) {
      await sendNotification(
        AppNotificationModel(
          id: '',
          userId: data['assigneeId'],
          workspaceId: data['workspaceId'],
          title: 'مهمة جديدة',
          body: 'تم إسناد مهمة جديدة لك: ${data['title']}',
          type: 'task_assigned',
          relatedId: docRef.id,
          createdAt: DateTime.now(),
        ),
      );
    }

    return docRef.id;
  }

  Future<void> sendNotification(AppNotificationModel notification) async {
    final docRef = _firestore.collection('notifications').doc();
    await docRef.set({...notification.toJson(), 'id': docRef.id});
  }

  Stream<List<AppNotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => AppNotificationModel.fromJson({...d.data(), 'id': d.id}),
              )
              .toList(),
        );
  }

  Stream<List<TaskModel>> getAssignedTasksStream(
    String workspaceId,
    String userId,
  ) {
    return _firestore
        .collection('tasks')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('assigneeId', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => TaskModel.fromJson({...d.data(), 'id': d.id}))
              .toList(),
        );
  }

  Stream<List<TaskModel>> getCreatedTasksStream(
    String workspaceId,
    String creatorId,
  ) {
    return _firestore
        .collection('tasks')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => TaskModel.fromJson({...d.data(), 'id': d.id}))
              .toList(),
        );
  }

  Stream<List<TaskModel>> getTaskHistoryStream(
    String workspaceId,
    String userId,
  ) {
    // History includes tasks where user is assignee OR creator AND status is 'completed'
    // Actually, for history we can just fetch all tasks where user was involved.
    // Since Firestore doesn't support easy OR across fields without a composite index or dual queries,
    // we can use combineLatest or just fetch all for workspace if small, but let's try to be efficient.

    final assigned = _firestore
        .collection('tasks')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('assigneeId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .snapshots();

    final created = _firestore
        .collection('tasks')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('creatorId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .snapshots();

    return Rx.combineLatest2(assigned, created, (
      QuerySnapshot a,
      QuerySnapshot b,
    ) {
      final docs = [...a.docs, ...b.docs];
      // remove duplicates by ID
      final seen = <String>{};
      final unique = <TaskModel>[];
      for (final d in docs) {
        if (!seen.contains(d.id)) {
          seen.add(d.id);
          unique.add(
            TaskModel.fromJson({
              ...d.data() as Map<String, dynamic>,
              'id': d.id,
            }),
          );
        }
      }
      unique.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return unique;
    });
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    final doc = await _firestore.collection('tasks').doc(taskId).get();
    if (!doc.exists) return null;
    return TaskModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    await _firestore.collection('tasks').doc(taskId).update(updates);
  }

  Future<void> submitTaskForReview({
    required TaskModel task,
    required String reviewerId,
    String reviewerRoleId = '',
  }) async {
    final updates = {
      'status': 'submitted_for_review',
      'assigneeId': reviewerId,
      'meta': {
        ...?task.meta,
        'lastSubmittedAt': DateTime.now().toIso8601String(),
        'reviewerRoleId': reviewerRoleId,
      },
    };
    await updateTask(task.id, updates);

    await sendNotification(
      AppNotificationModel(
        id: '',
        userId: reviewerId,
        workspaceId: task.workspaceId,
        title: 'مراجعة مهمة',
        body: 'قام أحدهم بتسليم مهمة للمراجعة: ${task.title}',
        type: 'task_submitted',
        relatedId: task.id,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> approveTask({required TaskModel task}) async {
    await updateTask(task.id, {
      'status': 'completed',
      'meta': {...?task.meta, 'completedAt': DateTime.now().toIso8601String()},
    });

    await sendNotification(
      AppNotificationModel(
        id: '',
        userId:
            task.creatorId, // Notify creator? Actually assignee already knows.
        // Wait, if I created it, I want to know it's done.
        workspaceId: task.workspaceId,
        title: 'اكتمال مهمة',
        body: 'تم الانتهاء من المهمة: ${task.title}',
        type: 'task_approved',
        relatedId: task.id,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> rejectTask({
    required TaskModel task,
    required String reason,
    required String returnAssigneeId,
  }) async {
    await updateTask(task.id, {
      'status': 'rejected',
      'assigneeId': returnAssigneeId,
      'meta': {
        ...?task.meta,
        'rejectedAt': DateTime.now().toIso8601String(),
        'rejectionReason': reason,
      },
    });

    await sendNotification(
      AppNotificationModel(
        id: '',
        userId: returnAssigneeId,
        workspaceId: task.workspaceId,
        title: 'مهمة مرفوضة',
        body: 'تم رفض تسليم المهمة: ${task.title}. السبب: $reason',
        type: 'task_rejected',
        relatedId: task.id,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
}
