// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoginCtrl)
const loginCtrlProvider = LoginCtrlProvider._();

final class LoginCtrlProvider
    extends $NotifierProvider<LoginCtrl, AsyncValue<void>> {
  const LoginCtrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginCtrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginCtrlHash();

  @$internal
  @override
  LoginCtrl create() => LoginCtrl();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$loginCtrlHash() => r'5aa991e64b50691fea4497c08b5a83a288570531';

abstract class _$LoginCtrl extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
