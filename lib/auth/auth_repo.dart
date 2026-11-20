import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthRepo {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepo(this._auth, this._firestore);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Stream<UserModel?> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromJson({...snapshot.data()!, 'uid': uid});
      }
      return null;
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    String? pfp,
    DateTime? dob,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = _auth.currentUser;

    if (user != null) {
      // Bounded: on a stalled network the account already exists, so don't
      // hold the sign-up flow forever. Firestore still commits the queued
      // write once the connection returns.
      await Future.wait([
        user.updateDisplayName(displayName),
        _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'displayName': displayName,
          'pfp': pfp ?? "",
          'dob': dob != null ? Timestamp.fromDate(dob) : null,
          'createdAt': FieldValue.serverTimestamp(),
        }),
      ]).timeout(const Duration(seconds: 8), onTimeout: () => const []);
    }
  }

  Future<void> updateUserMetadata({
    String? displayName,
    String? pfp,
    DateTime? dob,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final Map<String, dynamic> updates = {};
    if (displayName != null) {
      updates['displayName'] = displayName;
      await user.updateDisplayName(displayName);
    }
    if (pfp != null) updates['pfp'] = pfp;
    if (dob != null) updates['dob'] = Timestamp.fromDate(dob);

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update(updates);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}
