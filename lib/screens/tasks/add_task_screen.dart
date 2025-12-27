import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../workspace/workspace_prov.dart';
import '../../models/workspace_member_model.dart';
import '../../auth/auth_prov.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'normal';
  String? _selectedAssigneeId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.shade50,
        elevation: 1,
        title: Text(
          'إضافة مهمة جديدة',
          style: TextStyle(
            fontFamily: 'Alexandria',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.grey.shade600),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'تفاصيل المهمة',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Alexandria', fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'عنوان المهمة',
                      labelStyle: TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.purple.shade400,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال عنوان المهمة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descriptionController,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Alexandria', fontSize: 14),
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'وصف المهمة',
                      labelStyle: TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.purple.shade400,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'الإعدادات',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'نوع المهمة',
                      labelStyle: TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'normal', child: Text('عادية', style: TextStyle(fontFamily: 'Alexandria'))),
                      DropdownMenuItem(value: 'suggestion', child: Text('اقتراح', style: TextStyle(fontFamily: 'Alexandria'))),
                      DropdownMenuItem(value: 'urgent', child: Text('عاجلة', style: TextStyle(fontFamily: 'Alexandria'))),
                      DropdownMenuItem(value: 'very_urgent', child: Text('عاجلة جداً', style: TextStyle(fontFamily: 'Alexandria'))),
                    ],
                    onChanged: (v) => setState(() => _selectedType = v ?? 'normal'),
                  ),
                  const SizedBox(height: 14),
                Builder(builder: (context) {
                  final workspace = ref.watch(selectedWorkspaceProvider);
                  if (workspace == null) {
                    return const SizedBox();
                  }

                  final membersAsync = ref.watch(workspaceMembersProvider(workspace.id));

                  return membersAsync.when(
                    data: (members) {
                      // find current member role
                      final currentUid = ref.read(authRepoProvider).currentUser?.uid;
                      final currentMember = members.cast<WorkspaceMemberModel?>().firstWhere((m) => m?.uid == currentUid, orElse: () => null);
                      final currentRoleId = currentMember?.roleId;

                      // compute descendant roles of currentRoleId using workspace.scheme
                      Set<String> descendantRoles = {};
                      if (currentRoleId != null) {
                        final scheme = workspace.scheme ?? {};
                        final allRoleIds = workspace.roles?.keys.toList() ?? [];
                        for (final r in allRoleIds) {
                          var cur = r;
                          while (true) {
                            final parent = scheme[cur];
                            if (parent == null) break;
                            if (parent == currentRoleId) {
                              descendantRoles.add(r);
                              break;
                            }
                            if (parent == cur) break;
                            cur = parent;
                          }
                        }
                      }

                      final allowedAssignees = members.where((m) => m.roleId != null && descendantRoles.contains(m.roleId)).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _selectedAssigneeId,
                            decoration: InputDecoration(
                              labelText: 'تعيين إلى',
                              labelStyle: TextStyle(
                                fontFamily: 'Alexandria',
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            items: allowedAssignees
                                .map((m) => DropdownMenuItem(
                                      value: m.uid,
                                      child: Text(
                                        m.displayName,
                                        style: const TextStyle(fontFamily: 'Alexandria'),
                                      ),
                                    ))
                                .toList(),
                            onChanged: allowedAssignees.isEmpty ? null : (v) => setState(() => _selectedAssigneeId = v),
                            hint: Text(
                              allowedAssignees.isEmpty ? 'لا يوجد مستخدمين متاحين' : 'اختر شخصاً',
                              style: const TextStyle(fontFamily: 'Alexandria'),
                            ),
                            validator: (val) {
                              if (allowedAssignees.isNotEmpty && val == null) {
                                return 'الرجاء اختيار شخص للتعيين';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, _) => const SizedBox(),
                  );
                }),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final workspace = ref.read(selectedWorkspaceProvider);
                      final currentUser = ref.read(authRepoProvider).currentUser;
                      if (workspace == null || currentUser == null) return;

                      final data = {
                        'workspaceId': workspace.id,
                        'title': _titleController.text.trim(),
                        'description': _descriptionController.text.trim(),
                        'type': _selectedType,
                        'assigneeId': _selectedAssigneeId,
                        'creatorId': currentUser.uid,
                        'status': 'assigned',
                      };

                      try {
                        await ref.read(workspaceRepoProvider).createTask(data);
                        if (!mounted) return;
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء المهمة')));
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (!mounted) return;
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
                        }
                      }
                    }
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
                    'حفظ المهمة',
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}
