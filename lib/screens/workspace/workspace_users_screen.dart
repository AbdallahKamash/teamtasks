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
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRoleId;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _searchController.dispose();
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
        id: '', 
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

  Future<void> _updateRole(
    String memberId,
    String? currentRoleId,
    Map<String, String> roles,
  ) async {
    final newRole = await showDialog<String?>(
      context: context,
      builder: (context) =>
          _RoleSelectionDialog(currentRoleId: currentRoleId, roles: roles),
    );

    if (newRole == currentRoleId) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(workspaceRepoProvider)
          .updateMemberRole(widget.workspaceId, memberId, newRole);
    } catch (e) {
      _showError('حدث خطأ أثناء تحديث الدور: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  
  
  
  
  
  bool _roleHasAllAdminPermissions(
    String roleId,
    Map<String, dynamic> allRolePermissions,
  ) {
    final rolePerms = allRolePermissions[roleId];
    if (rolePerms is! Map<String, dynamic>) return false;

    const adminPermissions = {
      'people_delete',
      'people_add',
      'roles_add',
      'messages_edit',
      'tasks_add',
      'workspace_edit',
      'tasks_delete',
      'workspace_delete',
      'messages_delete',
      'roles_delete',
      'tasks_edit',
      'roles_edit',
      'people_edit',
      'messages_add',
    };

    
    for (final perm in adminPermissions) {
      if (rolePerms[perm] != true) {
        return false;
      }
    }
    return true;
  }

  
  Future<int> _getAdminMemberCount(String workspaceId) async {
    try {
      final repo = ref.read(workspaceRepoProvider);
      final rolePerms = await repo.getRolePermissions(workspaceId);
      final members = await repo.getWorkspaceMembers(workspaceId);

      int adminCount = 0;
      for (final member in members) {
        if (member.roleId != null &&
            _roleHasAllAdminPermissions(member.roleId!, rolePerms)) {
          adminCount++;
        }
      }
      return adminCount;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _removeMember(String memberId, String memberName,
      String? memberRoleId, Map<String, dynamic> rolePermissions) async {
    
    final isLastAdmin = memberRoleId != null &&
        _roleHasAllAdminPermissions(memberRoleId, rolePermissions) &&
        (await _getAdminMemberCount(widget.workspaceId)) <= 1;

    final currentUserId = ref.read(authRepoProvider).currentUser?.uid ?? '';
    final isDeletingSelf = memberId == currentUserId;

    if (isDeletingSelf && isLastAdmin) {
      _showError('لا يمكنك حذف نفسك - أنت الأدمن الوحيد في مساحة العمل');
      return;
    }

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'حذف عضو',
            style: TextStyle(fontFamily: 'Alexandria'),
          ),
          content: Text(
            'هل أنت متأكد من حذف $memberName من مساحة العمل؟',
            style: const TextStyle(fontFamily: 'Alexandria'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Alexandria'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'حذف',
                style: TextStyle(fontFamily: 'Alexandria'),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(workspaceRepoProvider)
          .removeMemberFromWorkspace(widget.workspaceId, memberId);

      if (!mounted) return;
      if (isDeletingSelf) {
        ref.read(routerProvider).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حذف العضو بنجاح',
            style: TextStyle(fontFamily: 'Alexandria'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('حدث خطأ أثناء الحذف: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspacesAsync = ref.watch(workspacesProvider);
    final membersAsync = ref.watch(
      workspaceMembersProvider(widget.workspaceId),
    );

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
                  createdAt: DateTime(1970),
                ),
        );

        if (workspace.id == '') {
          return const Scaffold(
            body: Center(child: Text('Workspace not found')),
          );
        }

        final roles = workspace.roles ?? {};

        
        final rolePermissionsFuture = ref
            .read(workspaceRepoProvider)
            .getRolePermissions(widget.workspaceId);

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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: _buildInviteCard(workspace, roles),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'قائمة الأعضاء',
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            
                          },
                          icon: const Icon(Icons.filter_list, size: 20),
                          label: const Text(
                            'تصفية',
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 13,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                membersAsync.when(
                  data: (members) {
                    final query = _searchController.text.toLowerCase();
                    final filteredMembers = members.where((m) {
                      return m.displayName.toLowerCase().contains(query) ||
                          m.email.toLowerCase().contains(query);
                    }).toList();

                    if (filteredMembers.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'لم يتم العثور على أعضاء',
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final member = filteredMembers[index];
                          final roleName = roles[member.roleId] ?? 'بدون مسمى';

                          return FutureBuilder<Map<String, dynamic>>(
                            future: rolePermissionsFuture,
                            builder: (context, snapshot) {
                              final rolePermissions = snapshot.data ?? {};

                              return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.purple.shade50,
                                        backgroundImage: member.pfp != null
                                            ? NetworkImage(member.pfp!)
                                            : null,
                                        child: member.pfp == null
                                            ? Text(
                                                member.displayName.isNotEmpty
                                                    ? member.displayName[0]
                                                          .toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  color: Colors.purple,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    member.displayName,
                                                    style: const TextStyle(
                                                      fontFamily: 'Alexandria',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              member.email,
                                              style: TextStyle(
                                                fontFamily: 'Alexandria',
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.work_outline,
                                              size: 14,
                                              color: Colors.blue.shade700,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              roleName,
                                              style: TextStyle(
                                                color: Colors.blue.shade800,
                                                fontSize: 12,
                                                fontFamily: 'Alexandria',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (member.roleId != null &&
                                          _roleHasAllAdminPermissions(
                                            member.roleId!,
                                            rolePermissions,
                                          ))
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.admin_panel_settings,
                                                size: 14,
                                                color: Colors.orange.shade700,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'أدمن',
                                                style: TextStyle(
                                                  color: Colors.orange.shade800,
                                                  fontSize: 12,
                                                  fontFamily: 'Alexandria',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  Row(
                                    children: [
                                      
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _updateRole(
                                            member.uid,
                                            member.roleId,
                                            roles,
                                          ),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'تعديل الدور',
                                            style: TextStyle(
                                              fontFamily: 'Alexandria',
                                              fontSize: 11,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.purple,
                                            side: BorderSide(
                                              color: Colors.purple.shade200,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      
                                      IconButton(
                                        onPressed: () => _removeMember(
                                          member.uid,
                                          member.displayName,
                                          member.roleId,
                                          rolePermissions,
                                        ),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                        ),
                                        style: IconButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          backgroundColor: Colors.red.shade50,
                                        ),
                                        tooltip: 'حذف العضو',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                            },
                          );
                        }, childCount: filteredMembers.length),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, s) => SliverFillRemaining(
                    child: Center(child: Text('حدث خطأ: $e')),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildInviteCard(WorkspaceModel workspace, Map<String, String> roles) {
    if (roles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.orange.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا يوجد أدوار في مساحة العمل هذه',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يجب إعداد هيكل الأدوار (مثل: مدير، موظف) قبل دعوة الآخرين.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref
                  .read(routerProvider)
                  .push('/edit-workspace-scheme', extra: workspace),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                elevation: 0,
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
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'دعوة عضو جديد',
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            style: const TextStyle(fontFamily: 'Alexandria'),
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
              labelStyle: const TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.purple),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedRoleId,
            items: roles.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: const TextStyle(fontFamily: 'Alexandria'),
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedRoleId = val),
            decoration: InputDecoration(
              labelText: 'تعيين الدور',
              labelStyle: const TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.work_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.purple),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _addUser(workspace),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
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
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSelectionDialog extends StatelessWidget {
  final String? currentRoleId;
  final Map<String, String> roles;

  const _RoleSelectionDialog({this.currentRoleId, required this.roles});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text(
          'تغيير الدور',
          style: TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: RadioGroup<String?>(
            groupValue: currentRoleId,
            onChanged: (val) => Navigator.of(context).pop(val),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: roles.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: const Text(
                      'بدون مسمى',
                      style: TextStyle(fontFamily: 'Alexandria'),
                    ),
                    leading: Radio<String?>(
                      value: null,
                    ),
                    onTap: () => Navigator.of(context).pop(null),
                  );
                }
                final entry = roles.entries.elementAt(index - 1);
                return ListTile(
                  title: Text(
                    entry.value,
                    style: const TextStyle(fontFamily: 'Alexandria'),
                  ),
                  leading: Radio<String?>(
                    value: entry.key,
                  ),
                  onTap: () => Navigator.of(context).pop(entry.key),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(currentRoleId),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Alexandria'),
            ),
          ),
        ],
      ),
    );
  }
}
