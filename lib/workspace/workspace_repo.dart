import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/workspace_model.dart';
import '../models/user_model.dart';
import '../models/pending_assignment_model.dart';

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

  Future<String> createWorkspace(WorkspaceModel workspace) async {
    // 1. Create the workspace document
    final workspaceRef = _firestore.collection('workspaces').doc();
    final workspaceWithId = workspace.copyWith(id: workspaceRef.id);

    await workspaceRef.set(workspaceWithId.toJson());

    // 2. Save to users_workspaces collection as requested
    await _firestore
        .collection('users_workspaces')
        .doc(workspace.creatorId)
        .set({
          'workspaces': FieldValue.arrayUnion([
            {'workspaceId': workspaceRef.id, 'role': 'admin'},
          ]),
        }, SetOptions(merge: true));

    return workspaceRef.id;
  }

  Future<void> updateWorkspace(WorkspaceModel workspace) async {
    await _firestore
        .collection('workspaces')
        .doc(workspace.id)
        .update(workspace.toJson());
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
}
