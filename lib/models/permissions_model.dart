/// Nested permissions model for cleaner access pattern
/// Usage: perms.workspace.edit, perms.tasks.add, etc.
class Permissions {
  final WorkspacePermissions workspace;
  final TasksPermissions tasks;
  final MessagesPermissions messages;
  final RolesPermissions roles;
  final PeoplePermissions people;

  Permissions({
    required this.workspace,
    required this.tasks,
    required this.messages,
    required this.roles,
    required this.people,
  });

  /// Create from flat permission map (from Firebase)
  factory Permissions.fromMap(Map<String, dynamic> map) {
    return Permissions(
      workspace: WorkspacePermissions(
        edit: map['workspace_edit'] == true,
        delete: map['workspace_delete'] == true,
      ),
      tasks: TasksPermissions(
        add: map['tasks_add'] == true,
        edit: map['tasks_edit'] == true,
        delete: map['tasks_delete'] == true,
      ),
      messages: MessagesPermissions(
        add: map['messages_add'] == true,
        edit: map['messages_edit'] == true,
        delete: map['messages_delete'] == true,
      ),
      roles: RolesPermissions(
        add: map['roles_add'] == true,
        edit: map['roles_edit'] == true,
        delete: map['roles_delete'] == true,
      ),
      people: PeoplePermissions(
        add: map['people_add'] == true,
        edit: map['people_edit'] == true,
        delete: map['people_delete'] == true,
      ),
    );
  }

  /// Convert to flat permission map (for Firebase)
  Map<String, bool> toMap() {
    return {
      'workspace_edit': workspace.edit,
      'workspace_delete': workspace.delete,
      'tasks_add': tasks.add,
      'tasks_edit': tasks.edit,
      'tasks_delete': tasks.delete,
      'messages_add': messages.add,
      'messages_edit': messages.edit,
      'messages_delete': messages.delete,
      'roles_add': roles.add,
      'roles_edit': roles.edit,
      'roles_delete': roles.delete,
      'people_add': people.add,
      'people_edit': people.edit,
      'people_delete': people.delete,
    };
  }

  /// Check if user is admin (has all permissions)
  bool get isAdmin {
    return workspace.edit &&
        workspace.delete &&
        tasks.add &&
        tasks.edit &&
        tasks.delete &&
        messages.add &&
        messages.edit &&
        messages.delete &&
        roles.add &&
        roles.edit &&
        roles.delete &&
        people.add &&
        people.edit &&
        people.delete;
  }

  @override
  String toString() => 'Permissions(workspace: $workspace, tasks: $tasks, '
      'messages: $messages, roles: $roles, people: $people)';
}

class WorkspacePermissions {
  final bool edit;
  final bool delete;

  WorkspacePermissions({
    required this.edit,
    required this.delete,
  });

  @override
  String toString() => 'WorkspacePermissions(edit: $edit, delete: $delete)';
}

class TasksPermissions {
  final bool add;
  final bool edit;
  final bool delete;

  TasksPermissions({
    required this.add,
    required this.edit,
    required this.delete,
  });

  @override
  String toString() => 'TasksPermissions(add: $add, edit: $edit, delete: $delete)';
}

class MessagesPermissions {
  final bool add;
  final bool edit;
  final bool delete;

  MessagesPermissions({
    required this.add,
    required this.edit,
    required this.delete,
  });

  @override
  String toString() => 'MessagesPermissions(add: $add, edit: $edit, delete: $delete)';
}

class RolesPermissions {
  final bool add;
  final bool edit;
  final bool delete;

  RolesPermissions({
    required this.add,
    required this.edit,
    required this.delete,
  });

  @override
  String toString() => 'RolesPermissions(add: $add, edit: $edit, delete: $delete)';
}

class PeoplePermissions {
  final bool add;
  final bool edit;
  final bool delete;

  PeoplePermissions({
    required this.add,
    required this.edit,
    required this.delete,
  });

  @override
  String toString() => 'PeoplePermissions(add: $add, edit: $edit, delete: $delete)';
}
