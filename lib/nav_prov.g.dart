// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_prov.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NavIndex)
final navIndexProvider = NavIndexProvider._();

final class NavIndexProvider extends $NotifierProvider<NavIndex, int> {
  NavIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navIndexHash();

  @$internal
  @override
  NavIndex create() => NavIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$navIndexHash() => r'0df0655623dd40fe91a48119b3f2e3ab67f859db';

abstract class _$NavIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
