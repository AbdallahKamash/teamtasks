// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_pref_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Synchronous access to SharedPreferences.
///
/// The instance is loaded once in `main()` and injected with
/// `sharedPreferencesProvider.overrideWithValue(prefs)`, so reads (like the
/// saved workspace) are available on the very first frame.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Synchronous access to SharedPreferences.
///
/// The instance is loaded once in `main()` and injected with
/// `sharedPreferencesProvider.overrideWithValue(prefs)`, so reads (like the
/// saved workspace) are available on the very first frame.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Synchronous access to SharedPreferences.
  ///
  /// The instance is loaded once in `main()` and injected with
  /// `sharedPreferencesProvider.overrideWithValue(prefs)`, so reads (like the
  /// saved workspace) are available on the very first frame.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'd8a123f8131dddc25218cf0b7e15eff43b58543c';
