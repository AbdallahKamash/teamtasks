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

String _$workspacesHash() => r'90c77fbb021e297c5954e609643c1c831da339f4';

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

String _$selectedWorkspaceHash() => r'007eed17738e8dff7a07b45404435cd6d84815c0';

@ProviderFor(isCurrentWorkspaceAdmin)
const isCurrentWorkspaceAdminProvider = IsCurrentWorkspaceAdminProvider._();

final class IsCurrentWorkspaceAdminProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const IsCurrentWorkspaceAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isCurrentWorkspaceAdminProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isCurrentWorkspaceAdminHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isCurrentWorkspaceAdmin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isCurrentWorkspaceAdminHash() =>
    r'9f90cb13d28c12e3aa7f1a9334af603733a81690';

@ProviderFor(workspaceMembers)
const workspaceMembersProvider = WorkspaceMembersFamily._();

final class WorkspaceMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkspaceMemberModel>>,
          List<WorkspaceMemberModel>,
          Stream<List<WorkspaceMemberModel>>
        >
    with
        $FutureModifier<List<WorkspaceMemberModel>>,
        $StreamProvider<List<WorkspaceMemberModel>> {
  const WorkspaceMembersProvider._({
    required WorkspaceMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workspaceMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workspaceMembersHash();

  @override
  String toString() {
    return r'workspaceMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<WorkspaceMemberModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WorkspaceMemberModel>> create(Ref ref) {
    final argument = this.argument as String;
    return workspaceMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkspaceMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workspaceMembersHash() => r'ba31dfcc886fd43cdfc4c181b362f3606beba38d';

final class WorkspaceMembersFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<WorkspaceMemberModel>>, String> {
  const WorkspaceMembersFamily._()
    : super(
        retry: null,
        name: r'workspaceMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkspaceMembersProvider call(String workspaceId) =>
      WorkspaceMembersProvider._(argument: workspaceId, from: this);

  @override
  String toString() => r'workspaceMembersProvider';
}
