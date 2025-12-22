import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workspace_model.dart';
import '../../models/pending_assignment_model.dart';
import '../../workspace/workspace_prov.dart';
import '../../auth/auth_prov.dart';

import '../../router/router.dart';

class WorkspaceUsersScreen extends ConsumerStatefulWidget {
  final String workspaceId;

  const WorkspaceUsersScreen({required this.workspaceId, super.key});

  @override
  ConsumerState<WorkspaceUsersScreen> createState() =>
      _WorkspaceUsersScreenState();
}

class _WorkspaceUsersScreenState extends ConsumerState<WorkspaceUsersScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _selectedRoleId;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addUser(WorkspaceModel workspace) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('يرجى إدخال البريد الإلكتروني');
      return;
    }
    if (_selectedRoleId == null) {
      _showError('يرجى اختيار الدور');
      return;
    }

    final currentUser = ref.read(authRepoProvider).currentUser;
    final currentUserEmail = currentUser?.email ?? "";
    if (currentUserEmail == email) {
      _showError('لا يمكن إضافة نفسك إلى مساحة العمل');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(workspaceRepoProvider);

      // Check if user is already pending
      final isPending = await repo.isUserPending(workspace.id, email);
      if (isPending) {
        _showError('المستخدم لديه دعوة معلقة بالفعل');
        return;
      }

      final user = await repo.getUserByEmail(email);

      if (user == null) {
        _showError('المستخدم غير موجود. يرجى التأكد من البريد الإلكتروني');
        return;
      }

      final inviterName = currentUser?.displayName ?? 'مستخدم';
      final inviterId = currentUser?.uid ?? '';

      final assignment = PendingAssignmentModel(
        id: '', // Repo will gen
        workspaceId: workspace.id,
        inviterName: inviterName,
        inviterId: inviterId,
        roleId: _selectedRoleId!,
        email: email,
        inviteeId: user.uid,
        createdAt: DateTime.now(),
      );

      await repo.addPendingAssignment(assignment);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تمت إضافة المستخدم بنجاح (بانتظار القبول)',
            style: TextStyle(fontFamily: 'Alexandria'),
          ),
          backgroundColor: Colors.green,
        ),
      );
      _emailController.clear();
      setState(() => _selectedRoleId = null);
    } catch (e) {
      _showError('حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Alexandria'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspacesAsync = ref.watch(workspacesProvider);

    return workspacesAsync.when(
      data: (workspaces) {
        final workspace = workspaces.firstWhere(
          (w) => w.id == widget.workspaceId,
          orElse: () => workspaces.isNotEmpty
              ? workspaces.first
              : WorkspaceModel(
                  id: '',
                  name: '',
                  color: '',
                  creatorId: '',
                  createdAt: DateTime(1970),
                ),
        );

        // If 'null as dynamic' above crashes, it's just a fallback dummy.
        // Realistically we handle not found:
        if (workspace.id == '') {
          return const Scaffold(
            body: Center(child: Text('Workspace not found')),
          );
        }

        final roles = workspace.roles ?? {};

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text(
              'أعضاء مساحة العمل',
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.grey.shade200,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (roles.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 48,
                            color: Colors.orange.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'لا يوجد أدوار في مساحة العمل هذه.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'يجب إضافة أدوار (مثل: مدير، موظف) قبل إضافة مستخدمين.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(routerProvider)
                                  .push(
                                    '/edit-workspace-scheme',
                                    extra: workspace,
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'إعداد الأدوار والهيكل',
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Add User Form Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إضافة مستخدم جديد',
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(fontFamily: 'Alexandria'),
                            decoration: InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              labelStyle: const TextStyle(
                                fontFamily: 'Alexandria',
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRoleId,
                            items: roles.entries.map((entry) {
                              return DropdownMenuItem(
                                value: entry.key, // ID
                                child: Text(
                                  entry.value, // Name
                                  style: const TextStyle(
                                    fontFamily: 'Alexandria',
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedRoleId = val),
                            decoration: InputDecoration(
                              labelText: 'تعيين الدور',
                              labelStyle: const TextStyle(
                                fontFamily: 'Alexandria',
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(Icons.work_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _addUser(workspace),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'إرسال الدعوة',
                                      style: TextStyle(
                                        fontFamily: 'Alexandria',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'سيتم إضافة المستخدم إلى قائمة "التعيينات المعلقة" بانتظار الموافقة أو التفعيل.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
