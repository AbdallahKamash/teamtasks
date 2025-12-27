import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../workspace/workspace_prov.dart';
import '../../models/workspace_member_model.dart';
import '../../auth/auth_prov.dart';
import '../../router/router.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final TaskModel task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _reasonCtrl = TextEditingController();

  String _getStatusLabel(String status) {
    switch (status) {
      case 'assigned':
        return 'مُعينة';
      case 'submitted_for_review':
        return 'قيد المراجعة';
      case 'completed':
        return 'منتهية';
      case 'rejected':
        return 'مرفوضة';
      default:
        return status;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'very_urgent':
        return 'عاجلة جداً';
      case 'urgent':
        return 'عاجلة';
      case 'suggestion':
        return 'اقتراح';
      default:
        return 'عادية';
    }
  }

  Color _getPriorityColor(String type) {
    switch (type) {
      case 'very_urgent':
        return Colors.red.shade600;
      case 'urgent':
        return Colors.orange.shade600;
      case 'suggestion':
        return Colors.blue.shade400;
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final currentUser = ref.read(authRepoProvider).currentUser;
    final workspace = ref.read(selectedWorkspaceProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          task.title,
          style: const TextStyle(
            fontFamily: 'Alexandria',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.grey.shade800,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.grey.shade600),
          onPressed: () => ref.read(routerProvider).pop(),
        ),
        actions: [_buildActions(task)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'التفاصيل',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        task.description,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'النوع',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'Alexandria',
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(
                                    task.type,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getTypeLabel(task.type),
                                  style: TextStyle(
                                    fontFamily: 'Alexandria',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _getPriorityColor(task.type),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'الحالة',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'Alexandria',
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatusLabel(task.status),
                                  style: TextStyle(
                                    fontFamily: 'Alexandria',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // mark as finished -> submit to next reviewer
                    if (workspace == null) return;
                    final members = await ref
                        .read(workspaceRepoProvider)
                        .getWorkspaceMembers(workspace.id);

                    WorkspaceMemberModel? currentMember;
                    try {
                      currentMember = members.firstWhere(
                        (m) => m.uid == currentUser?.uid,
                      );
                    } catch (_) {
                      currentMember = null;
                    }

                    String? parentRole;
                    if (currentMember != null && workspace.scheme != null) {
                      parentRole = workspace.scheme![currentMember.roleId];
                    } else {
                      parentRole = null;
                    }

                    if (parentRole == null) {
                      // no parent role -> complete
                      await ref
                          .read(workspaceRepoProvider)
                          .approveTask(task: task);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إنهاء المهمة')),
                      );
                      ref.read(routerProvider).pop();
                      return;
                    }

                    // find any member with parentRole
                    WorkspaceMemberModel? reviewer;
                    try {
                      reviewer = members.firstWhere(
                        (m) => m.roleId == parentRole,
                      );
                    } catch (_) {
                      reviewer = null;
                    }

                    if (reviewer == null) {
                      // no reviewer found, mark completed
                      await ref
                          .read(workspaceRepoProvider)
                          .approveTask(task: task);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إنهاء المهمة')),
                      );
                      ref.read(routerProvider).pop();
                      return;
                    }

                    await ref
                        .read(workspaceRepoProvider)
                        .submitTaskForReview(
                          task: task,
                          reviewerId: reviewer.uid,
                          reviewerRoleId: parentRole,
                        );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال المهمة للمراجعة')),
                    );
                    ref.read(routerProvider).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'وضع علامة كمنتهية (أرسل للمراجعة)',
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (currentUser != null &&
                    task.status == 'submitted_for_review' &&
                    currentUser.uid == task.assigneeId) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'قرار المراجع',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _reasonCtrl,
                          textDirection: TextDirection.rtl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'ملاحظات (إذا رفضت)',
                            labelStyle: TextStyle(
                              fontFamily: 'Alexandria',
                              color: Colors.grey.shade600,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.purple.shade400,
                                width: 2,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontFamily: 'Alexandria'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Approve
                                  await ref
                                      .read(workspaceRepoProvider)
                                      .approveTask(task: task);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم الموافقة'),
                                    ),
                                  );
                                  ref.read(routerProvider).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade500,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'موافقة',
                                  style: TextStyle(
                                    fontFamily: 'Alexandria',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final reason = _reasonCtrl.text.trim();
                                  final returnAssignee = task.creatorId;
                                  await ref
                                      .read(workspaceRepoProvider)
                                      .rejectTask(
                                        task: task,
                                        reason: reason,
                                        returnAssigneeId: returnAssignee,
                                      );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم الرفض')),
                                  );
                                  ref.read(routerProvider).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade500,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'رفض',
                                  style: TextStyle(
                                    fontFamily: 'Alexandria',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(TaskModel task) {
    final permsAsync = ref.watch(currentUserPermissionsProvider);

    return permsAsync.when(
      data: (perms) {
        return Row(
          children: [
            if (perms.tasks.edit)
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                onPressed: () =>
                    ref.read(routerProvider).push('/add-task', extra: task),
              ),
            if (perms.tasks.delete)
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: Colors.red),
                onPressed: () => _confirmDelete(task),
              ),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_, _) => const SizedBox(),
    );
  }

  void _confirmDelete(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'حذف المهمة',
          style: TextStyle(fontFamily: 'Alexandria'),
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذه المهمة؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(fontFamily: 'Alexandria'),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(routerProvider).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Alexandria'),
            ),
          ),
          TextButton(
            onPressed: () async {
              ref.read(routerProvider).pop();
              await ref.read(workspaceRepoProvider).deleteTask(task.id);
              ref.read(routerProvider).pop();
            },
            child: const Text(
              'حذف',
              style: TextStyle(fontFamily: 'Alexandria', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
