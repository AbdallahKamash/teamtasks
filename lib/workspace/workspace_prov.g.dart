// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_prov.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workspaceRepo)
const workspaceRepoProvider = WorkspaceRepoProvider._();

final class WorkspaceRepoProvider
    extends $FunctionalProvider<WorkspaceRepo, WorkspaceRepo, WorkspaceRepo>
    with $Provider<WorkspaceRepo> {
  const WorkspaceRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspaceRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspaceRepoHash();

  @$internal
  @override
  $ProviderElement<WorkspaceRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WorkspaceRepo create(Ref ref) {
    return workspaceRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkspaceRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkspaceRepo>(value),
    );
  }
}

String _$workspaceRepoHash() => r'ee84bb7a811902f3f365af9c2389230c5a4c6ed9';

@ProviderFor(workspaces)
const workspacesProvider = WorkspacesProvider._();

final class WorkspacesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkspaceModel>>,
          List<WorkspaceModel>,
          Stream<List<WorkspaceModel>>
        >
    with
        $FutureModifier<List<WorkspaceModel>>,
        $StreamProvider<List<WorkspaceModel>> {
  const WorkspacesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspacesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspacesHash();

  @$internal
  @override
  $StreamProviderElement<List<WorkspaceModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WorkspaceModel>> create(Ref ref) {
    return workspaces(ref);
  }
}

String _$workspacesHash() => r'02a9ef1ba12c8925970b5e5620ef59d4dd58e4b2';

@ProviderFor(SelectedWorkspaceId)
const selectedWorkspaceIdProvider = SelectedWorkspaceIdProvider._();

final class SelectedWorkspaceIdProvider
    extends $NotifierProvider<SelectedWorkspaceId, String?> {
  const SelectedWorkspaceIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedWorkspaceIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedWorkspaceIdHash();

  @$internal
  @override
  SelectedWorkspaceId create() => SelectedWorkspaceId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedWorkspaceIdHash() =>
    r'01eabbd0b6379316ad11b54f5e2bdec0ffac622d';

abstract class _$SelectedWorkspaceId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(selectedWorkspace)
const selectedWorkspaceProvider = SelectedWorkspaceProvider._();

final class SelectedWorkspaceProvider
    extends
        $FunctionalProvider<WorkspaceModel?, WorkspaceModel?, WorkspaceModel?>
    with $Provider<WorkspaceModel?> {
  const SelectedWorkspaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedWorkspaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedWorkspaceHash();

  @$internal
  @override
  $ProviderElement<WorkspaceModel?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WorkspaceModel? create(Ref ref) {
    return selectedWorkspace(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkspaceModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkspaceModel?>(value),
    );
  }
}

String _$selectedWorkspaceHash() => r'1b92040628e5af8ffea2c65d603ad55417ea28c1';
