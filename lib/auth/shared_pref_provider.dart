import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_pref_provider.g.dart';

/// Synchronous access to SharedPreferences.
///
/// The instance is loaded once in `main()` and injected with
/// `sharedPreferencesProvider.overrideWithValue(prefs)`, so reads (like the
/// saved workspace) are available on the very first frame.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
}

/// Helper constants for SharedPreferences keys
class SharedPrefKeys {
  /// Legacy, app-wide key (read once as a fallback, then migrated).
  static const String selectedWorkspaceId = 'selected_workspace_id';

  /// Per-user key, so switching accounts never restores another user's
  /// workspace.
  static String selectedWorkspaceIdFor(String uid) =>
      'selected_workspace_id_$uid';
}
