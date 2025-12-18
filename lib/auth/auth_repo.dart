import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepo {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepo(this._auth, this._firestore);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    String role = 'user',
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = _auth.currentUser;

    if (user != null) {
      await user.updateDisplayName(displayName);

      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': displayName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
