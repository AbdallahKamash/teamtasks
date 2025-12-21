import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_repo.dart';
import '../models/user_model.dart';

part 'auth_prov.g.dart';

@riverpod
FirebaseAuth fbAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@riverpod
FirebaseFirestore fbFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@riverpod
AuthRepo authRepo(Ref ref) {
  return AuthRepo(ref.read(fbAuthProvider), ref.read(fbFirestoreProvider));
}

@riverpod
Stream<UserModel?> currentUserData(Ref ref) {
  final user = ref.watch(authRepoProvider).currentUser;
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(authRepoProvider).getUserDataStream(user.uid);
}
