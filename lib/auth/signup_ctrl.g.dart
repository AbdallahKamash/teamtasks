// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SignUpCtrl)
const signUpCtrlProvider = SignUpCtrlProvider._();

final class SignUpCtrlProvider
    extends $NotifierProvider<SignUpCtrl, AsyncValue<void>> {
  const SignUpCtrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpCtrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpCtrlHash();

  @$internal
  @override
  SignUpCtrl create() => SignUpCtrl();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$signUpCtrlHash() => r'd26726d272de924f1786acc8acb2efc38f51fad9';

abstract class _$SignUpCtrl extends $Notifier<AsyncValue<void>> {
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
