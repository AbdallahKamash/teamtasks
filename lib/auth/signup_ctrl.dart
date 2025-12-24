import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:teamtasks/auth/auth_prov.dart';

part 'signup_ctrl.g.dart';

@riverpod
class SignUpCtrl extends _$SignUpCtrl {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepoProvider)
          .signUp(email: email, password: password, displayName: displayName);
    });
  }
}
