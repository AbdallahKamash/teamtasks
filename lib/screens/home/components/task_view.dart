import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../../models/task_model.dart';
import '../../../models/workspace_member_model.dart';
import '../../../workspace/workspace_prov.dart';

class TaskView extends ConsumerStatefulWidget {
  final Stream<List<TaskModel>> taskStream;
  final String title;
  final String workspaceName;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<TaskModel> Function(List<TaskModel>)? filter;

  const TaskView({
    super.key,
    required this.taskStream,
    required this.title,
    required this.workspaceName,
    required this.emptyMessage,
    required this.emptyIcon,
    this.filter,
  });

  @override
  ConsumerState<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends ConsumerState<TaskView> {
  final Map<String, bool> _sectionExpanded = {
    'جاري العمل': true,
    'قيد المراجعة': true,
    'مرفوضة': true,
    'مكتملة': true,
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: .ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(widget.title, widget.workspaceName),
              Expanded(
                child: StreamBuilder<List<TaskModel>>(
                  stream: widget.taskStream,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var tasks = snap.data ?? [];
                    if (widget.filter != null) {
                      tasks = widget.filter!(tasks);
                    }
      
                    if (tasks.isEmpty) {
                      return _buildEmptyState(
                        widget.emptyMessage,
                        widget.emptyIcon,
                      );
                    }
      
                    return _buildGroupedTaskList(tasks);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String workspaceName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.purple.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Alexandria',
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedTaskList(List<TaskModel> tasks) {
    final worked = tasks
        .where((t) => t.status == 'assigned' || t.status == 'under_review')
        .toList();
    final pending = tasks
        .where((t) => t.status == 'submitted_for_review')
        .toList();
    final rejected = tasks.where((t) => t.status == 'rejected').toList();
    final completed = tasks.where((t) => t.status == 'completed').toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        if (worked.isNotEmpty) _buildSection('جاري العمل', worked, Colors.blue),
        if (pending.isNotEmpty)
          _buildSection('قيد المراجعة', pending, Colors.orange),
        if (rejected.isNotEmpty) _buildSection('مرفوضة', rejected, Colors.red),
        if (completed.isNotEmpty)
          _buildSection('مكتملة', completed, Colors.green),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSection(
    String title,
    List<TaskModel> sectionTasks,
    Color color,
  ) {
    bool isExpanded = _sectionExpanded[title] ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _sectionExpanded[title] = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  isExpanded
                      ? Icons.expand_more_rounded
                      : Icons.chevron_left_rounded,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
                const Spacer(),
                Text(
                  '(${sectionTasks.length})',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...sectionTasks.map((t) => TaskItem(task: t)),
      ],
    );
  }
}

class TaskItem extends ConsumerWidget {
  final TaskModel task;
  const TaskItem({super.key, required this.task});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(selectedWorkspaceProvider);
    final membersAsync = workspace != null
        ? ref.watch(workspaceMembersProvider(workspace.id))
        : const AsyncValue<List<WorkspaceMemberModel>>.loading();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/task-detail', extra: task),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(
                          task.type,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getTypeLabel(task.type),
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getPriorityColor(task.type),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      child: Text(
                        task.title,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                membersAsync.when(
                  data: (members) {
                    final assignee = members
                        .where((m) => m.uid == task.assigneeId)
                        .firstOrNull;
                    if (assignee == null) return const SizedBox();
                    final roleName =
                        workspace?.roles?[assignee.roleId] ?? 'بدون دور';
                    return Text(
                      '${assignee.displayName} - $roleName',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 11,
                        color: Colors.purple.shade300,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDateTime(task.createdAt),
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    _buildStatusChip(task.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    String label;
    Color color;
    switch (status) {
      case 'assigned':
        label = 'مُعينة';
        color = Colors.blue;
        break;
      case 'submitted_for_review':
        label = 'بانتظار المراجعة';
        color = Colors.orange;
        break;
      case 'under_review':
        label = 'قيد التدقيق';
        color = Colors.purple;
        break;
      case 'completed':
        label = 'مكتملة';
        color = Colors.green;
        break;
      case 'rejected':
        label = 'مرفوضة';
        color = Colors.red;
        break;
      default:
        label = status;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Alexandria',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return intl.DateFormat('yyyy/MM/dd HH:mm').format(date);
  }
}
