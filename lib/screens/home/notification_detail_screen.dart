import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/auth/auth_prov.dart';
import 'package:teamtasks/models/pending_assignment_model.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';

class NotificationDetailScreen extends ConsumerWidget {
  final PendingAssignmentModel assignment;

  const NotificationDetailScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentUserDataProvider); // Keep it alive
    final workspaceAsync = ref.watch(
      workspaceByIdProvider(assignment.workspaceId),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: workspaceAsync.when(
        data: (workspace) {
          if (workspace == null) {
            return const Center(
              child: Text('عذراً، مساحة العمل هذه لم تعد موجودة'),
            );
          }

          final roleTitle =
              workspace.roles?[assignment.roleId] ?? assignment.roleId;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Workspace Logo/Color
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _hexToColor(workspace.color),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _hexToColor(workspace.color).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: workspace.logoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                workspace.logoUrl!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                          : Text(
                              workspace.name.isEmpty
                                  ? ''
                                  : workspace.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 48,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Alexandria',
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    workspace.name,
                    style: const TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (workspace.description != null &&
                      workspace.description!.isNotEmpty) ...[
                    Text(
                      workspace.description!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  const Divider(),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    context,
                    label: 'المرسل',
                    value: assignment.inviterName,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    label: 'الدور المقترح',
                    value: roleTitle,
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _accept(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'قبول الانضمام',
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _reject(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'رفض الدعوة',
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey.shade700, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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
      Navigator.pop(context); // Close detail
      Navigator.pop(context); // Close notifications list
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم قبول الدعوة بنجاح')));
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    await ref.read(workspaceRepoProvider).rejectAssignment(assignment.id);
    if (context.mounted) {
      Navigator.pop(context); // Close detail
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم رفض الدعوة')));
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
