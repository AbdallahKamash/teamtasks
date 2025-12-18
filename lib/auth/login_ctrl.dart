import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:teamtasks/auth/auth_prov.dart';

part 'login_ctrl.g.dart';

@riverpod
class LoginCtrl extends _$LoginCtrl {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepoProvider).signIn(email: email, password: password);
    });
  }
}
