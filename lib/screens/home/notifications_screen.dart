import 'package:material_ui/material_ui.dart';
import 'package:teamtasks/components/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/router/router.dart';
import 'package:teamtasks/auth/auth_prov.dart';
import 'package:teamtasks/models/pending_assignment_model.dart';
import 'package:teamtasks/models/notification_model.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentUserDataProvider);
    final pendingAssignmentsAsync = ref.watch(pendingAssignmentsProvider);
    final appNotificationsAsync = ref.watch(appNotificationsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.grey.shade100,
        shadowColor: Colors.grey.shade50,
        title: const Text(
          'التنبيهات',
          style: TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => ref.read(routerProvider).pop(),
        ),
      ),
      body: _buildList(pendingAssignmentsAsync, appNotificationsAsync),
    );
  }

  Widget _buildList(
    AsyncValue<List<PendingAssignmentModel>> pending,
    AsyncValue<List<AppNotificationModel>> app,
  ) {
    if (pending.isLoading || app.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<dynamic> all = [];
    all.addAll(pending.value ?? []);
    all.addAll(app.value ?? []);

    // sort by date
    all.sort((a, b) {
      final da = a is PendingAssignmentModel
          ? a.createdAt
          : (a as AppNotificationModel).createdAt;
      final db = b is PendingAssignmentModel
          ? b.createdAt
          : (b as AppNotificationModel).createdAt;
      return db.compareTo(da);
    });

    if (all.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد تنبيهات حالياً',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: all.length,
      itemBuilder: (context, index) {
        final item = all[index];
        if (item is PendingAssignmentModel) {
          return _NotificationCard(assignment: item);
        } else {
          return _AppNotificationCard(
            notification: item as AppNotificationModel,
          );
        }
      },
    );
  }
}

class _AppNotificationCard extends ConsumerWidget {
  final AppNotificationModel notification;
  const _AppNotificationCard({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    IconData icon;
    Color color;
    switch (notification.type) {
      case 'task_assigned':
        icon = Icons.assignment_rounded;
        color = Colors.blue;
        break;
      case 'task_submitted':
        icon = Icons.rate_review_rounded;
        color = Colors.orange;
        break;
      case 'task_approved':
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case 'task_rejected':
        icon = Icons.cancel_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = Colors.purple;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: TextStyle(
                fontFamily: 'Alexandria',
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _timeAgo(notification.createdAt),
              style: TextStyle(
                fontFamily: 'Alexandria',
                color: Colors.grey.shade400,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return 'منذ ${diff.inMinutes} دقيقة';
    return 'الآن';
  }
}

class _NotificationCard extends ConsumerWidget {
  final PendingAssignmentModel assignment;

  const _NotificationCard({required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(
      workspaceByIdProvider(assignment.workspaceId),
    );

    return workspaceAsync.when(
      data: (workspace) {
        if (workspace == null) return const SizedBox.shrink();

        final roleTitle =
            workspace.roles?[assignment.roleId] ?? assignment.roleId;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            onHover: (value) {},
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              ref
                  .read(routerProvider)
                  .push('/notification-detail', extra: assignment);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _hexToColor(
                            workspace.color,
                          ).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.work_outline_rounded,
                          color: _hexToColor(workspace.color),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assignment.inviterName,
                              style: const TextStyle(
                                fontFamily: 'Alexandria',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'يرغب في إضافتك إلى ${workspace.name}',
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'الدور: $roleTitle',
                      style: const TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _accept(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'قبول',
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _reject(context, ref),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'رفض',
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    final user = ref.read(fbAuthProvider).currentUser;
    if (user == null) return;

    final userData = ref.read(currentUserDataProvider).value;

    await ref
        .read(workspaceRepoProvider)
        .acceptAssignment(
          assignment,
          user.uid,
          userData?.displayName ?? user.displayName,
          user.email,
        );

    if (context.mounted) {
      Toast.success('تم قبول الدعوة بنجاح');
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    await ref.read(workspaceRepoProvider).rejectAssignment(assignment.id);
    if (context.mounted) {
      Toast.info('تم رفض الدعوة');
    }
  }

  Color _hexToColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
