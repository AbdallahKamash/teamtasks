// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_prov.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workspaceRepo)
final workspaceRepoProvider = WorkspaceRepoProvider._();

final class WorkspaceRepoProvider
    extends $FunctionalProvider<WorkspaceRepo, WorkspaceRepo, WorkspaceRepo>
    with $Provider<WorkspaceRepo> {
  WorkspaceRepoProvider._()
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

/// Ids of the signed-in user's workspaces.
///
/// Only rebuilds when the user id changes, so auth events that keep the same
/// user don't restart the Firestore listener.

@ProviderFor(workspaceIds)
final workspaceIdsProvider = WorkspaceIdsProvider._();

/// Ids of the signed-in user's workspaces.
///
/// Only rebuilds when the user id changes, so auth events that keep the same
/// user don't restart the Firestore listener.

final class WorkspaceIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// Ids of the signed-in user's workspaces.
  ///
  /// Only rebuilds when the user id changes, so auth events that keep the same
  /// user don't restart the Firestore listener.
  WorkspaceIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspaceIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspaceIdsHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return workspaceIds(ref);
  }
}

String _$workspaceIdsHash() => r'0c59b6d1687c65f02e549847efb5574efcdba511';

/// The signed-in user's workspaces, newest first.
///
/// Rebuilds (with a fresh query) whenever the set of ids changes — e.g. right
/// after creating, joining or leaving a workspace. While it reloads it keeps
/// the previous list, so the UI never blanks out.

@ProviderFor(workspaces)
final workspacesProvider = WorkspacesProvider._();

/// The signed-in user's workspaces, newest first.
///
/// Rebuilds (with a fresh query) whenever the set of ids changes — e.g. right
/// after creating, joining or leaving a workspace. While it reloads it keeps
/// the previous list, so the UI never blanks out.

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
  /// The signed-in user's workspaces, newest first.
  ///
  /// Rebuilds (with a fresh query) whenever the set of ids changes — e.g. right
  /// after creating, joining or leaving a workspace. While it reloads it keeps
  /// the previous list, so the UI never blanks out.
  WorkspacesProvider._()
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

String _$workspacesHash() => r'0f7df4349b7b8b3a46883fcc5a5f2c8313cccc8f';

/// The id of the workspace the user picked, persisted per user.
///
/// Read synchronously from SharedPreferences, so the right workspace is
/// selected on the first frame after launch. Only rebuilds when the signed-in
/// user changes (not on every auth event such as token refreshes).

@ProviderFor(SelectedWorkspaceId)
final selectedWorkspaceIdProvider = SelectedWorkspaceIdProvider._();

/// The id of the workspace the user picked, persisted per user.
///
/// Read synchronously from SharedPreferences, so the right workspace is
/// selected on the first frame after launch. Only rebuilds when the signed-in
/// user changes (not on every auth event such as token refreshes).
final class SelectedWorkspaceIdProvider
    extends $NotifierProvider<SelectedWorkspaceId, String?> {
  /// The id of the workspace the user picked, persisted per user.
  ///
  /// Read synchronously from SharedPreferences, so the right workspace is
  /// selected on the first frame after launch. Only rebuilds when the signed-in
  /// user changes (not on every auth event such as token refreshes).
  SelectedWorkspaceIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedWorkspaceIdProvider',
        isAutoDispose: false,
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
    r'480b5eb65a9c77f0d9bdeacf6a37238722d73dc9';

/// The id of the workspace the user picked, persisted per user.
///
/// Read synchronously from SharedPreferences, so the right workspace is
/// selected on the first frame after launch. Only rebuilds when the signed-in
/// user changes (not on every auth event such as token refreshes).

abstract class _$SelectedWorkspaceId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The workspace currently shown.
///
/// Pure derivation with no side effects: the saved choice if it is in the
/// list, otherwise the newest workspace. Keeps the previous list while the
/// stream reloads, so the UI never blanks out.

@ProviderFor(selectedWorkspace)
final selectedWorkspaceProvider = SelectedWorkspaceProvider._();

/// The workspace currently shown.
///
/// Pure derivation with no side effects: the saved choice if it is in the
/// list, otherwise the newest workspace. Keeps the previous list while the
/// stream reloads, so the UI never blanks out.

final class SelectedWorkspaceProvider
    extends
        $FunctionalProvider<WorkspaceModel?, WorkspaceModel?, WorkspaceModel?>
    with $Provider<WorkspaceModel?> {
  /// The workspace currently shown.
  ///
  /// Pure derivation with no side effects: the saved choice if it is in the
  /// list, otherwise the newest workspace. Keeps the previous list while the
  /// stream reloads, so the UI never blanks out.
  SelectedWorkspaceProvider._()
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

String _$selectedWorkspaceHash() => r'0bc36ff91d17764fa53c56a8a0474ff6de68bf6b';

@ProviderFor(workspaceMembers)
final workspaceMembersProvider = WorkspaceMembersFamily._();

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
  WorkspaceMembersProvider._({
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
  WorkspaceMembersFamily._()
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

@ProviderFor(rolePermissions)
final rolePermissionsProvider = RolePermissionsFamily._();

final class RolePermissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          Stream<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $StreamProvider<Map<String, dynamic>> {
  RolePermissionsProvider._({
    required RolePermissionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rolePermissionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rolePermissionsHash();

  @override
  String toString() {
    return r'rolePermissionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return rolePermissions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RolePermissionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rolePermissionsHash() => r'9f82787739796859f9fa9e57b83cb115929fe5f8';

final class RolePermissionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, dynamic>>, String> {
  RolePermissionsFamily._()
    : super(
        retry: null,
        name: r'rolePermissionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RolePermissionsProvider call(String workspaceId) =>
      RolePermissionsProvider._(argument: workspaceId, from: this);

  @override
  String toString() => r'rolePermissionsProvider';
}

@ProviderFor(pendingAssignments)
final pendingAssignmentsProvider = PendingAssignmentsProvider._();

final class PendingAssignmentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PendingAssignmentModel>>,
          List<PendingAssignmentModel>,
          Stream<List<PendingAssignmentModel>>
        >
    with
        $FutureModifier<List<PendingAssignmentModel>>,
        $StreamProvider<List<PendingAssignmentModel>> {
  PendingAssignmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingAssignmentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingAssignmentsHash();

  @$internal
  @override
  $StreamProviderElement<List<PendingAssignmentModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PendingAssignmentModel>> create(Ref ref) {
    return pendingAssignments(ref);
  }
}

String _$pendingAssignmentsHash() =>
    r'8a6c16ba99b52e6a23740445134516db25ed7238';

@ProviderFor(workspaceById)
final workspaceByIdProvider = WorkspaceByIdFamily._();

final class WorkspaceByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkspaceModel?>,
          WorkspaceModel?,
          FutureOr<WorkspaceModel?>
        >
    with $FutureModifier<WorkspaceModel?>, $FutureProvider<WorkspaceModel?> {
  WorkspaceByIdProvider._({
    required WorkspaceByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workspaceByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workspaceByIdHash();

  @override
  String toString() {
    return r'workspaceByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WorkspaceModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WorkspaceModel?> create(Ref ref) {
    final argument = this.argument as String;
    return workspaceById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkspaceByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workspaceByIdHash() => r'e172317339a0bf88940efb4f12c74f0b285edb56';

final class WorkspaceByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WorkspaceModel?>, String> {
  WorkspaceByIdFamily._()
    : super(
        retry: null,
        name: r'workspaceByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkspaceByIdProvider call(String workspaceId) =>
      WorkspaceByIdProvider._(argument: workspaceId, from: this);

  @override
  String toString() => r'workspaceByIdProvider';
}

/// The signed-in user's permissions in the selected workspace.
///
/// Derived synchronously from the members and role-permission streams, so it
/// keeps its last value while those reload (no flicker of tabs/FAB).

@ProviderFor(currentUserPermissions)
final currentUserPermissionsProvider = CurrentUserPermissionsProvider._();

/// The signed-in user's permissions in the selected workspace.
///
/// Derived synchronously from the members and role-permission streams, so it
/// keeps its last value while those reload (no flicker of tabs/FAB).

final class CurrentUserPermissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Permissions>,
          AsyncValue<Permissions>,
          AsyncValue<Permissions>
        >
    with $Provider<AsyncValue<Permissions>> {
  /// The signed-in user's permissions in the selected workspace.
  ///
  /// Derived synchronously from the members and role-permission streams, so it
  /// keeps its last value while those reload (no flicker of tabs/FAB).
  CurrentUserPermissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserPermissionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserPermissionsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<Permissions>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<Permissions> create(Ref ref) {
    return currentUserPermissions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Permissions> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Permissions>>(value),
    );
  }
}

String _$currentUserPermissionsHash() =>
    r'8cf6f0899546e5e3d35beebbdb683e36222e86a2';

@ProviderFor(appNotifications)
final appNotificationsProvider = AppNotificationsProvider._();

final class AppNotificationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppNotificationModel>>,
          List<AppNotificationModel>,
          Stream<List<AppNotificationModel>>
        >
    with
        $FutureModifier<List<AppNotificationModel>>,
        $StreamProvider<List<AppNotificationModel>> {
  AppNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appNotificationsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppNotificationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppNotificationModel>> create(Ref ref) {
    return appNotifications(ref);
  }
}

String _$appNotificationsHash() => r'100c97321eb260f2cd419beaa4fa95b6fc31c14e';

@ProviderFor(assignedTasks)
final assignedTasksProvider = AssignedTasksFamily._();

final class AssignedTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskModel>>,
          List<TaskModel>,
          Stream<List<TaskModel>>
        >
    with $FutureModifier<List<TaskModel>>, $StreamProvider<List<TaskModel>> {
  AssignedTasksProvider._({
    required AssignedTasksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'assignedTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assignedTasksHash();

  @override
  String toString() {
    return r'assignedTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TaskModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskModel>> create(Ref ref) {
    final argument = this.argument as String;
    return assignedTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AssignedTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assignedTasksHash() => r'3ec6f996cdcef4c059e511f7c4415ece25f3a8d7';

final class AssignedTasksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TaskModel>>, String> {
  AssignedTasksFamily._()
    : super(
        retry: null,
        name: r'assignedTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AssignedTasksProvider call(String workspaceId) =>
      AssignedTasksProvider._(argument: workspaceId, from: this);

  @override
  String toString() => r'assignedTasksProvider';
}

@ProviderFor(createdTasks)
final createdTasksProvider = CreatedTasksFamily._();

final class CreatedTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskModel>>,
          List<TaskModel>,
          Stream<List<TaskModel>>
        >
    with $FutureModifier<List<TaskModel>>, $StreamProvider<List<TaskModel>> {
  CreatedTasksProvider._({
    required CreatedTasksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'createdTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createdTasksHash();

  @override
  String toString() {
    return r'createdTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TaskModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskModel>> create(Ref ref) {
    final argument = this.argument as String;
    return createdTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CreatedTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createdTasksHash() => r'9790012c7b62945344e7b8d8f56ea8aaaa6d7dac';

final class CreatedTasksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TaskModel>>, String> {
  CreatedTasksFamily._()
    : super(
        retry: null,
        name: r'createdTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreatedTasksProvider call(String workspaceId) =>
      CreatedTasksProvider._(argument: workspaceId, from: this);

  @override
  String toString() => r'createdTasksProvider';
}

@ProviderFor(taskHistory)
final taskHistoryProvider = TaskHistoryFamily._();

final class TaskHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskModel>>,
          List<TaskModel>,
          Stream<List<TaskModel>>
        >
    with $FutureModifier<List<TaskModel>>, $StreamProvider<List<TaskModel>> {
  TaskHistoryProvider._({
    required TaskHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskHistoryHash();

  @override
  String toString() {
    return r'taskHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TaskModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskModel>> create(Ref ref) {
    final argument = this.argument as String;
    return taskHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskHistoryHash() => r'166cbd18da1cb5f03958fa9cd8fbd8ddd09651be';

final class TaskHistoryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TaskModel>>, String> {
  TaskHistoryFamily._()
    : super(
        retry: null,
        name: r'taskHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TaskHistoryProvider call(String workspaceId) =>
      TaskHistoryProvider._(argument: workspaceId, from: this);

  @override
  String toString() => r'taskHistoryProvider';
}
