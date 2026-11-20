import 'dart:ui' as ui;
import 'package:material_ui/material_ui.dart';
import 'package:teamtasks/auth/auth_errors.dart';
import 'package:teamtasks/components/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../workspace/workspace_prov.dart';
import '../../models/workspace_member_model.dart';
import '../../auth/auth_prov.dart';
import '../../router/router.dart';
import '../../models/task_model.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final TaskModel? task;
  const AddTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'normal';
  String? _selectedAssigneeId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedType = widget.task!.type;
      _selectedAssigneeId = widget.task!.assigneeId;
    }
  }

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
          widget.task != null ? 'تعديل المهمة' : 'إضافة مهمة جديدة',
          style: TextStyle(
            fontFamily: 'Alexandria',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.grey.shade600),
          onPressed: () => ref.read(routerProvider).pop(),
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
                    textDirection: ui.TextDirection.rtl,
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
                    textDirection: ui.TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 14,
                    ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                    textDirection: ui.TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 14,
                    ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'الإعدادات',
                    textDirection: ui.TextDirection.rtl,
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
                        borderSide: BorderSide(
                          color: Colors.purple.shade400,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'normal',
                        child: Text(
                          'عادية',
                          style: TextStyle(fontFamily: 'Alexandria'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'suggestion',
                        child: Text(
                          'اقتراح',
                          style: TextStyle(fontFamily: 'Alexandria'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'urgent',
                        child: Text(
                          'عاجلة',
                          style: TextStyle(fontFamily: 'Alexandria'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'very_urgent',
                        child: Text(
                          'عاجلة جداً',
                          style: TextStyle(fontFamily: 'Alexandria'),
                        ),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _selectedType = v ?? 'normal'),
                  ),
                  const SizedBox(height: 14),
                  Builder(
                    builder: (context) {
                      final workspace = ref.watch(selectedWorkspaceProvider);
                      if (workspace == null) {
                        return const SizedBox();
                      }

                      final membersAsync = ref.watch(
                        workspaceMembersProvider(workspace.id),
                      );

                      return membersAsync.when(
                        data: (members) {
                          // find current member role
                          final currentUid = ref
                              .read(authRepoProvider)
                              .currentUser
                              ?.uid;
                          final currentMember = members
                              .cast<WorkspaceMemberModel?>()
                              .firstWhere(
                                (m) => m?.uid == currentUid,
                                orElse: () => null,
                              );
                          final currentRoleId = currentMember?.roleId;

                          // compute descendant roles of currentRoleId using workspace.scheme
                          Set<String> descendantRoles = {};
                          if (currentRoleId != null) {
                            final scheme = workspace.scheme ?? {};
                            final allRoleIds =
                                workspace.roles?.keys.toList() ?? [];
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

                          final allowedAssignees = members
                              .where(
                                (m) =>
                                    m.roleId != null &&
                                    descendantRoles.contains(m.roleId),
                              )
                              .toList();

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
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                                items: allowedAssignees
                                    .map(
                                      (m) => DropdownMenuItem(
                                        value: m.uid,
                                        child: Text(
                                          m.displayName,
                                          style: const TextStyle(
                                            fontFamily: 'Alexandria',
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: allowedAssignees.isEmpty
                                    ? null
                                    : (v) => setState(
                                        () => _selectedAssigneeId = v,
                                      ),
                                hint: Text(
                                  allowedAssignees.isEmpty
                                      ? 'لا يوجد مستخدمين متاحين'
                                      : 'اختر شخصاً',
                                  style: const TextStyle(
                                    fontFamily: 'Alexandria',
                                  ),
                                ),
                                validator: (val) {
                                  if (allowedAssignees.isNotEmpty &&
                                      val == null) {
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
                    },
                  ),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              final workspace = ref.read(
                                selectedWorkspaceProvider,
                              );
                              final currentUser = ref
                                  .read(authRepoProvider)
                                  .currentUser;
                              if (workspace == null || currentUser == null) {
                                setState(() => _isLoading = false);
                                return;
                              }

                              final data = {
                                'workspaceId': workspace.id,
                                'title': _titleController.text.trim(),
                                'description': _descriptionController.text
                                    .trim(),
                                'type': _selectedType,
                                'assigneeId': _selectedAssigneeId,
                                'workerId':
                                    widget.task?.workerId ??
                                    _selectedAssigneeId,
                                'creatorId':
                                    widget.task?.creatorId ?? currentUser.uid,
                                'status': widget.task?.status ?? 'assigned',
                              };

                              try {
                                if (widget.task != null) {
                                  await ref
                                      .read(workspaceRepoProvider)
                                      .updateTask(widget.task!.id, data);
                                } else {
                                  await ref
                                      .read(workspaceRepoProvider)
                                      .createTask(data);
                                }
                                if (!context.mounted) return;
                                Toast.success(
                                  widget.task != null
                                      ? 'تم تحديث المهمة'
                                      : 'تم إنشاء المهمة',
                                );
                                ref.read(routerProvider).pop();
                              } catch (e) {
                                setState(() => _isLoading = false);
                                if (!context.mounted) return;
                                debugPrint('$e');
                                Toast.error(
                                  widget.task != null
                                      ? 'تعذّر تحديث المهمة'
                                      : 'تعذّر إنشاء المهمة',
                                  message: describeAuthError(e).message,
                                );
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
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.task != null
                                ? 'حفظ التعديلات'
                                : 'حفظ المهمة',
                            style: const TextStyle(
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
