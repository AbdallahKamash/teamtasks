import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_pref_provider.g.dart';

@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

/// Helper constants for SharedPreferences keys
class SharedPrefKeys {
  static const String selectedWorkspaceId = 'selected_workspace_id';
}
