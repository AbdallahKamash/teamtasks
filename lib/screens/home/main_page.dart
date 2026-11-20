import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/components/bottom_navbar.dart';
import 'package:teamtasks/components/fade_through_indexed_stack.dart';
import 'package:teamtasks/components/workspace_swapper.dart';
import 'package:teamtasks/screens/home/my_tasks_screen.dart';
import 'package:teamtasks/screens/home/assigned_tasks_screen.dart';
import 'package:teamtasks/screens/home/task_history_screen.dart';
import 'package:teamtasks/screens/home/workspace_settings.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';
import 'package:teamtasks/router/router.dart';
import '../../components/app_drawer.dart';
import '../../nav_prov.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  Widget build(BuildContext context) {
    final perm = ref.watch(currentUserPermissionsProvider);

    final bool editWorkspace = perm.when(
      data: (perms) => perms.workspace.edit,
      loading: () => false,
      error: (_, _) => false,
    );

    final bool addTasks = perm.when(
      data: (perms) => perms.tasks.add,
      loading: () => false,
      error: (_, _) => false,
    );

    // If the workspace-settings tab disappears (permission lost), fall back to
    // tab 0 in this same build so the tabs fade once, straight to tab 0.
    final requestedIndex = ref.watch(navIndexProvider);
    final currentIndex = (!editWorkspace && requestedIndex >= 3)
        ? 0
        : requestedIndex;
    if (currentIndex != requestedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navIndexProvider.notifier).setIndex(0);
      });
    }

    return Scaffold(
      drawerEnableOpenDragGesture: false,
      backgroundColor: Colors.grey.shade200,
      bottomNavigationBar: const BottomNavbar(),
      floatingActionButton: addTasks ? _buildFloatingActionButton() : null,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        actions: [_buildNotificationStack()],
        backgroundColor: Colors.grey.shade200,
        shadowColor: Colors.grey.shade50,
        elevation: 1,
        leadingWidth: 50,
        leading: Builder(
          builder: (context) {
            return IconButton(
              padding: const EdgeInsets.all(8),
              icon: Icon(Icons.menu_rounded, color: Colors.grey.shade600),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: const WorkspaceSwapper(),
      ),
      drawer: const AppDrawer(),
      // Tabs fade through (no sideways sweep) and keep their state.
      body: FadeThroughIndexedStack(
        index: currentIndex,
        children: [
          const MyTasksScreen(),
          const AssignedTasksScreen(),
          const TaskHistoryScreen(),
          if (editWorkspace) const WorkspaceSettings(),
        ],
      ),
    );
  }

  Widget _buildNotificationStack() {
    final pendingAssignmentsAsync = ref.watch(pendingAssignmentsProvider);

    return pendingAssignmentsAsync.when(
      data: (assignments) {
        final hasNotifications = assignments.isNotEmpty;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                hasNotifications
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: hasNotifications ? Colors.purple : Colors.grey.shade600,
              ),
              onPressed: () {
                ref.read(routerProvider).push('/notifications');
              },
            ),
            if (hasNotifications)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => IconButton(
        icon: Icon(
          Icons.notifications_none_rounded,
          color: Colors.grey.shade600,
        ),
        onPressed: null,
      ),
      error: (_, _) => IconButton(
        icon: Icon(
          Icons.notifications_none_rounded,
          color: Colors.grey.shade600,
        ),
        onPressed: null,
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    final currentIndex = ref.watch(navIndexProvider);
    final selectedWorkspace = ref.watch(selectedWorkspaceProvider);
    if ((currentIndex == 0 || currentIndex == 1) && selectedWorkspace != null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: FloatingActionButton(
          onPressed: () {
            ref.read(routerProvider).push('/add-task');
          },
          backgroundColor: Colors.grey.shade200,
          elevation: 1,
          child: Icon(Icons.add_rounded, color: Colors.grey.shade700, size: 36),
        ),
      );
    }
    return null;
  }
}
