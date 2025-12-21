import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:teamtasks/auth/auth_prov.dart';

part 'signup_ctrl.g.dart';

@riverpod
class SignUpCtrl extends _$SignUpCtrl {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  /// Sign up user with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Set state to loading
    state = const AsyncLoading();

    // Guard for errors
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepoProvider)
          .signUp(email: email, password: password, displayName: displayName);
    });
  }
}
