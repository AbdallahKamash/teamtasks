import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/auth_prov.dart';
import '../../../workspace/workspace_prov.dart';
import 'components/task_view.dart';

class TaskHistoryScreen extends ConsumerWidget {
  const TaskHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWorkspace = ref.watch(selectedWorkspaceProvider);
    final currentUser = ref.watch(authStateProvider).value;

    if (selectedWorkspace == null) {
      return _buildNoWorkspaceView();
    }

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return TaskView(
      taskStream: ref
          .watch(workspaceRepoProvider)
          .getTaskHistoryStream(selectedWorkspace.id, currentUser.uid),
      title: 'سجل المهام',
      workspaceName: selectedWorkspace.name,
      emptyMessage: 'سجل المهام فارغ',
      emptyIcon: Icons.history_rounded,
    );
  }

  Widget _buildNoWorkspaceView() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد مساحة عمل\nقم بإضافة مساحة عمل جديدة من الأعلى',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontFamily: 'Alexandria',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
