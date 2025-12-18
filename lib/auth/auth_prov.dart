import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_repo.dart';

part 'auth_prov.g.dart';

@riverpod
FirebaseAuth fbAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@riverpod
FirebaseFirestore fbfs(Ref ref) {
  return FirebaseFirestore.instance;
}

@riverpod
AuthRepo authRepo(Ref ref) {
  return AuthRepo(ref.read(fbAuthProvider), ref.read(fbfsProvider));
}

@riverpod
Stream<User?> authState(Ref ref) {
  return ref.read(authRepoProvider).authStateChanges();
}
