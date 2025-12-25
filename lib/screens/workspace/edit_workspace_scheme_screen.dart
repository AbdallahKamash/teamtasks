import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teamtasks/models/workspace_model.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';

class EditWorkspaceSchemeScreen extends ConsumerStatefulWidget {
  final WorkspaceModel workspace;

  const EditWorkspaceSchemeScreen({super.key, required this.workspace});

  @override
  ConsumerState<EditWorkspaceSchemeScreen> createState() =>
      _EditWorkspaceSchemeScreenState();
}

class _EditWorkspaceSchemeScreenState
    extends ConsumerState<EditWorkspaceSchemeScreen> {
  
  late Map<String, String> _roles;
  
  late Map<String, String> _scheme;
  
  late Map<String, Map<String, bool>> _permissions;  
  final Set<String> _expandedRoles = {};  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _roles = Map.from(widget.workspace.roles ?? {});
    _scheme = Map.from(widget.workspace.scheme ?? {});
    _permissions = {};
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final perms = await ref
            .read(workspaceRepoProvider)
            .getRolePermissions(widget.workspace.id);

        if (!mounted) return;
        setState(() {
          
          perms.forEach((roleId, val) {
            if (val is Map) {
              _permissions[roleId] = Map<String, bool>.from(val.map((k, v) => MapEntry(k.toString(), v == true)));
            }
          });
        });
      } catch (e) {
        // Handle error silently
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addRole() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    
    if (_roles.containsValue(title)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('المسمى موجود بالفعل')));
      return;
    }

    
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    setState(() {
      _roles[id] = title;
      
      _permissions[id] = {
        'tasks_add': false,
        'tasks_edit': false,
        'tasks_delete': false,
        'messages_add': false,
        'messages_edit': false,
        'messages_delete': false,
        'workspace_edit': false,
        'workspace_delete': false,
        'roles_add': false,
        'roles_edit': false,
        'roles_delete': false,
        'people_add': false,
        'people_edit': false,
        'people_delete': false,
      };
      _titleController.clear();
    });
  }

  Future<void> _removeRole(String roleId) async {
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(workspaceRepoProvider);

      
      final pendingCount = await repo.getPendingAssignmentsCountForRole(
        widget.workspace.id,
        roleId,
      );

      if (pendingCount > 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن حذف الدور: يوجد $pendingCount دعوات معلقة بهذا الدور',
              style: const TextStyle(fontFamily: 'Alexandria'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      
      final activeCount = await repo.getActiveMembersCountForRole(
        widget.workspace.id,
        roleId,
      );

      if (activeCount > 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن حذف الدور: يوجد $activeCount أعضاء حاليين بهذا الدور',
              style: const TextStyle(fontFamily: 'Alexandria'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _roles.remove(roleId);
        
        _scheme.remove(roleId);
        _scheme.removeWhere((key, value) => value == roleId);
        
        _permissions.remove(roleId);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ أثناء التحقق: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, bool> _ensurePermissionEntry(String roleId) {
    if (!_permissions.containsKey(roleId)) {
      _permissions[roleId] = {
        'tasks_add': false,
        'tasks_edit': false,
        'tasks_delete': false,
        'messages_add': false,
        'messages_edit': false,
        'messages_delete': false,
        'workspace_edit': false,
        'workspace_delete': false,
        'roles_add': false,
        'roles_edit': false,
        'roles_delete': false,
        'people_add': false,
        'people_edit': false,
        'people_delete': false,
      };
    }
    return _permissions[roleId]!;
  }

  bool _hasAllPermissions(Map<String, bool> perms) {
    return perms.values.every((v) => v == true);
  }

  void _updateScheme(String roleId, String? managerId) {
    setState(() {
      if (managerId == null) {
        _scheme.remove(roleId);
      } else {
        if (roleId == managerId) return;
        
        if (_scheme[managerId] == roleId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا يمكن إنشاء حلقة دائرية')),
          );
          return;
        }
        _scheme[roleId] = managerId;
      }
    });
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedWorkspace = widget.workspace.copyWith(
        roles: _roles,
        scheme: _scheme,
      );

      await ref.read(workspaceRepoProvider).updateWorkspace(updatedWorkspace);
      
      try {
        await ref
            .read(workspaceRepoProvider)
            .updateRolePermissions(widget.workspace.id, _permissions);
      } catch (e) {
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ أثناء حفظ الأذونات: $e')),
          );
        }
      }

      // Invalidate cached providers to force refresh
      ref.invalidate(rolePermissionsProvider(widget.workspace.id));
      ref.invalidate(currentUserPermissionsProvider);
      ref.invalidate(workspacesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الهيكل التنظيمي بنجاح')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    
    final roleEntries = _roles.entries.toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.grey.shade100,
        shadowColor: Colors.grey.shade50,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تعديل الهيكل التنظيمي',
          style: TextStyle(
            fontFamily: 'Alexandria',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                const Text(
                  'إضافة مسمى وظيفي جديد',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'أدخل المسمى الوظيفي (مثال: مدير)',
                          hintStyle: const TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _addRole,
                        icon: const Icon(Icons.add_rounded, color: Colors.purple),
                        tooltip: 'إضافة',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'المسميات والعلاقات',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _roles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_tree_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا يوجد مسميات وظيفية بعد',
                                style: TextStyle(
                                  fontFamily: 'Alexandria',
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: roleEntries.length,
                          padding: const EdgeInsets.only(bottom: 80),
                          itemBuilder: (context, index) {
                            final entry = roleEntries[index];
                            final roleId = entry.key;
                            final roleName = entry.value;
                            final managerId = _scheme[roleId];

                            
                            final possibleManagers = roleEntries
                                .where((e) => e.key != roleId)
                                .toList();

                            final isExpanded = _expandedRoles.contains(roleId);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide.none,
                              ),
                              elevation: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_expandedRoles.contains(roleId)) {
                                            _expandedRoles.remove(roleId);
                                          } else {
                                            _expandedRoles.add(roleId);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                roleName,
                                                style: const TextStyle(
                                                  fontFamily: 'Alexandria',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  _removeRole(roleId),
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: Colors.red.shade400,
                                                size: 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                            Icon(
                                              isExpanded
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: Colors.grey.shade600,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  if (isExpanded)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Divider(
                                            color: Colors.grey.shade300,
                                            height: 1,
                                          ),
                                          const SizedBox(height: 12),
                                          
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'يتبع لـ: ',
                                                  style: TextStyle(
                                                    fontFamily: 'Alexandria',
                                                    color:
                                                        Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                          isExpanded: true,
                                                          value: managerId,
                                                          icon: Icon(
                                                            Icons
                                                                .keyboard_arrow_down,
                                                            color: Colors.grey
                                                                .shade600,
                                                            size: 20,
                                                          ),
                                                          hint: Text(
                                                            '—',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Alexandria',
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .grey
                                                                  .shade800,
                                                            ),
                                                          ),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Alexandria',
                                                            fontSize: 14,
                                                            color: Colors.grey
                                                                .shade800,
                                                          ),
                                                          items: [
                                                            const DropdownMenuItem<
                                                              String
                                                            >(
                                                              value: null,
                                                              child: Text(
                                                                  '— (لا أحد)'),
                                                            ),
                                                            ...possibleManagers
                                                                .map((m) {
                                                              return DropdownMenuItem<
                                                                String
                                                              >(
                                                                value: m.key,
                                                                child: Text(
                                                                    m.value),
                                                              );
                                                            }),
                                                          ],
                                                          onChanged: (val) =>
                                                              _updateScheme(
                                                                  roleId, val),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          
                                          Builder(builder: (context) {
                                            final entry =
                                                _ensurePermissionEntry(
                                                    roleId);

                                            void setPerm(String key, bool val) {
                                              // If unchecking a permission
                                              if (!val) {
                                                // Check if this role currently has all permissions
                                                if (_hasAllPermissions(entry)) {
                                                  // Check if there's another role with all permissions
                                                  final otherRolesWithAll = _permissions.entries
                                                      .where((e) =>
                                                          e.key != roleId &&
                                                          _hasAllPermissions(
                                                              e.value))
                                                      .length;

                                                  if (otherRolesWithAll == 0) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'يجب أن يكون لديك على الأقل مسمى واحد بجميع الأذونات',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Alexandria',
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                        duration: Duration(
                                                            seconds: 2),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                }
                                              }

                                              setState(() {
                                                entry[key] = val;
                                              });
                                            }

                                            Widget permCheckbox(
                                              String key,
                                              String label,
                                            ) {
                                              return Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  Checkbox(
                                                    value:
                                                        entry[key] ?? false,
                                                    onChanged: (v) =>
                                                        setPerm(
                                                            key, v == true),
                                                  ),
                                                  Text(
                                                    label,
                                                    style: const TextStyle(
                                                      fontFamily: 'Alexandria',
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                
                                                Text('المهام',
                                                    style: TextStyle(
                                                        fontFamily: 'Alexandria',
                                                        color: Colors.grey
                                                            .shade700)),
                                                Row(
                                                  children: [
                                                    permCheckbox(
                                                        'tasks_add', 'إضافة'),
                                                    permCheckbox(
                                                        'tasks_edit', 'تعديل'),
                                                    permCheckbox(
                                                        'tasks_delete', 'حذف'),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text('الرسائل',
                                                    style: TextStyle(
                                                        fontFamily: 'Alexandria',
                                                        color: Colors.grey
                                                            .shade700)),
                                                Row(
                                                  children: [
                                                    permCheckbox(
                                                        'messages_add',
                                                        'إضافة'),
                                                    permCheckbox(
                                                        'messages_edit',
                                                        'تعديل'),
                                                    permCheckbox(
                                                        'messages_delete',
                                                        'حذف'),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text('مساحة العمل',
                                                    style: TextStyle(
                                                        fontFamily: 'Alexandria',
                                                        color: Colors.grey
                                                            .shade700)),
                                                Row(
                                                  children: [
                                                    permCheckbox(
                                                        'workspace_edit',
                                                        'تعديل'),
                                                    permCheckbox(
                                                        'workspace_delete',
                                                        'حذف'),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text('المسميات',
                                                    style: TextStyle(
                                                        fontFamily: 'Alexandria',
                                                        color: Colors.grey
                                                            .shade700)),
                                                Row(
                                                  children: [
                                                    permCheckbox(
                                                        'roles_add', 'إضافة'),
                                                    permCheckbox(
                                                        'roles_edit', 'تعديل'),
                                                    permCheckbox(
                                                        'roles_delete', 'حذف'),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text('الأشخاص',
                                                    style: TextStyle(
                                                        fontFamily: 'Alexandria',
                                                        color: Colors.grey
                                                            .shade700)),
                                                Row(
                                                  children: [
                                                    permCheckbox(
                                                        'people_add', 'إضافة'),
                                                    permCheckbox(
                                                        'people_edit', 'تعديل'),
                                                    permCheckbox(
                                                        'people_delete', 'حذف'),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'حفظ التغييرات',
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
