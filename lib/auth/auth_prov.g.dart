// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_prov.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fbAuth)
const fbAuthProvider = FbAuthProvider._();

final class FbAuthProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  const FbAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fbAuthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fbAuthHash();

  @$internal
  @override
  $ProviderElement<FirebaseAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseAuth create(Ref ref) {
    return fbAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAuth>(value),
    );
  }
}

String _$fbAuthHash() => r'9f4c98f2cdd2909d6e4117d3c7ad971151d94869';

@ProviderFor(fbfs)
const fbfsProvider = FbfsProvider._();

final class FbfsProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  const FbfsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fbfsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fbfsHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return fbfs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$fbfsHash() => r'fe906ae935fbea79141d0165ace89f91cf5b60a6';

@ProviderFor(authRepo)
const authRepoProvider = AuthRepoProvider._();

final class AuthRepoProvider
    extends $FunctionalProvider<AuthRepo, AuthRepo, AuthRepo>
    with $Provider<AuthRepo> {
  const AuthRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepoHash();

  @$internal
  @override
  $ProviderElement<AuthRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepo create(Ref ref) {
    return authRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepo>(value),
    );
  }
}

String _$authRepoHash() => r'4645b4be77f2c167d23c792aa335508848996ba1';

@ProviderFor(authState)
const authStateProvider = AuthStateProvider._();

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  const AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'2f6c8c4838ee8ca9ff4746c4b713587bb1538c12';
