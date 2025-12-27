import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';
import '../nav_prov.dart';

class BottomNavbar extends ConsumerWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final perm = ref.watch(currentUserPermissionsProvider);
    final workspacesAsync = ref.watch(workspacesProvider);

    final bool hasWorkspaces = workspacesAsync.when(
      data: (workspaces) => workspaces.isNotEmpty,
      loading: () => false,
      error: (_, _) => false,
    );

    final bool editWorkspace = perm.when(
      data: (perms) => perms.workspace.edit,
      loading: () => false,
      error: (_, _) => false,
    );

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 1,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.grey.shade200,
        currentIndex: currentIndex >= (editWorkspace ? 4 : 3)
            ? 0
            : currentIndex,
        onTap: (index) {
          if (index != 0 && !hasWorkspaces) {
            return;
          }
          if (index == 3 && !editWorkspace) {
            return;
          }
          ref.read(navIndexProvider.notifier).setIndex(index);
        },
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: Colors.grey.shade900,
        unselectedItemColor: Colors.grey.shade400,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        iconSize: 32,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment_ind_rounded,
              color: !hasWorkspaces ? Colors.grey.shade300 : null,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history_rounded,
              color: !hasWorkspaces ? Colors.grey.shade300 : null,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_rounded,
              color: !hasWorkspaces || !editWorkspace
                  ? Colors.grey.shade300
                  : null,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
