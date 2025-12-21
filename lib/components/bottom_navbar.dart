import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';
import '../nav_prov.dart';

class BottomNavbar extends ConsumerWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final workspacesAsync = ref.watch(workspacesProvider);

    final bool hasWorkspaces = workspacesAsync.when(
      data: (workspaces) => workspaces.isNotEmpty,
      loading: () => false,
      error: (_, __) => false,
    );

    return Container(
      // This mimics the elevation look of an AppBar
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300, // Soft shadow color
            blurRadius: 1, // Matches low elevation
            spreadRadius: 0,
            offset: const Offset(0, -2), // Move shadow UPWARDS
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.grey.shade200,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index != 0 && !hasWorkspaces) {
            // Ignore taps on other tabs if no workspace is available
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
            icon: Icon(Icons.home_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment_rounded,
              color: !hasWorkspaces ? Colors.grey.shade300 : null,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.group_rounded,
              color: !hasWorkspaces ? Colors.grey.shade300 : null,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_rounded,
              color: !hasWorkspaces ? Colors.grey.shade300 : null,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
