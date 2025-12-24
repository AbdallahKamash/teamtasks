import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/workspace_model.dart';
import '../models/user_model.dart';
import '../models/pending_assignment_model.dart';
import '../models/workspace_member_model.dart';

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

          // Handle new structure: 'workspaces' list of maps
          if (data['workspaces'] != null) {
            final List<dynamic> workspacesList = data['workspaces'];
            for (final w in workspacesList) {
              if (w is Map && w['workspaceId'] != null) {
                workspaceIds.add(w['workspaceId'] as String);
              }
            }
          }
          // Fallback/Legacy: 'workspaceIds' list of strings
          else if (data['workspaceIds'] != null) {
            workspaceIds.addAll(List<String>.from(data['workspaceIds']));
          }

          if (workspaceIds.isEmpty) {
            return Stream.value([]);
          }

          // Query workspaces where the document ID is in the list of IDs
          // Note: 'whereIn' supports up to 10 values. If users can have more,
          // we'd need to chunk this. Assuming < 10 for now as per plan.
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

                // Sort by creation time (newest first)
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
    // 1. Create a default "admin" role with all permissions
    final adminRoleId = DateTime.now().microsecondsSinceEpoch.toString();
    final defaultRoles = {adminRoleId: 'Admin'};
    final defaultPermissions = {
      adminRoleId: {
        'tasks_add': true,
        'tasks_edit': true,
        'tasks_delete': true,
        'messages_add': true,
        'messages_edit': true,
        'messages_delete': true,
        'workspace_edit': true,
        'workspace_delete': true,
        'roles_add': true,
        'roles_edit': true,
        'roles_delete': true,
        'people_add': true,
        'people_edit': true,
        'people_delete': true,
      },
    };

    // 2. Create the workspace document with the creator as the first admin
    final workspaceRef = _firestore.collection('workspaces').doc();
    final workspaceWithId = workspace.copyWith(
      id: workspaceRef.id,
      admins: [creatorId],
      roles: defaultRoles,
    );

    await workspaceRef.set(workspaceWithId.toJson());

    // 3. Save role permissions
    await workspaceRef.update({
      'rolePermissions': defaultPermissions,
    });

    // 4. Save to users_workspaces collection
    await _firestore.collection('users_workspaces').doc(creatorId).set({
      'workspaces': FieldValue.arrayUnion([
        {'workspaceId': workspaceRef.id},
      ]),
    }, SetOptions(merge: true));

    // 5. Add creator to members subcollection with the admin role assigned
    final member = WorkspaceMemberModel(
      uid: creatorId,
      email: creatorEmail,
      displayName: creatorName,
      joinedAt: DateTime.now(),
      roleId: adminRoleId, // Assign to the admin role
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

  /// Read role permissions map stored on the workspace document under
  /// the `rolePermissions` (or `permissions`) key. Returns empty map if none.
  Future<Map<String, dynamic>> getRolePermissions(String workspaceId) async {
    final doc = await _firestore.collection('workspaces').doc(workspaceId).get();
    if (!doc.exists) return {};
    final data = doc.data();
    if (data == null) return {};
    final perms = data['rolePermissions'] ?? data['permissions'];
    if (perms is Map<String, dynamic>) return perms;
    return {};
  }

  /// Overwrite role permissions map on workspace document. The map shape is
  /// Map<roleId, Map<permissionKey, bool>>.
  Future<void> updateRolePermissions(String workspaceId, Map<String, dynamic> perms) async {
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
    // Ensure uid is included if it's not in the data map
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
    // 1. Get all members of this workspace to clean up their users_workspaces
    final membersSnapshot = await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('members')
        .get();

    // 2. Remove workspace from each member's users_workspaces
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

      // Delete the member document
      await memberDoc.reference.delete();
    }

    // 3. Delete pending assignments
    final pendingQuery = await _firestore
        .collection('pending_assignments')
        .where('workspaceId', isEqualTo: workspaceId)
        .get();

    for (final doc in pendingQuery.docs) {
      await doc.reference.delete();
    }

    // 4. Delete workspace document
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
    // 1. Add to members subcollection
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

    // 2. Add to users_workspaces
    await _firestore.collection('users_workspaces').doc(userId).set({
      'workspaces': FieldValue.arrayUnion([
        {'workspaceId': assignment.workspaceId},
      ]),
    }, SetOptions(merge: true));

    // 3. Delete pending assignment
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

  /// Get all members of a workspace (Future-based)
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
    // 1. Remove from members subcollection
    await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('members')
        .doc(memberId)
        .delete();

    // 2. Remove from users_workspaces
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

  Future<void> updateWorkspaceAdmins(
    String workspaceId,
    List<String> adminIds,
  ) async {
    await _firestore.collection('workspaces').doc(workspaceId).update({
      'admins': adminIds,
    });
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

    // Also link in users_workspaces
    await _firestore.collection('users_workspaces').doc(member.uid).set({
      'workspaces': FieldValue.arrayUnion([
        {'workspaceId': workspaceId},
      ]),
    }, SetOptions(merge: true));
  }
}
