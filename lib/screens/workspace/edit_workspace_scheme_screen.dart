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
  // Roles: Map<ID, Name>
  late Map<String, String> _roles;
  // Scheme: Role ID -> Manager Role ID
  late Map<String, String> _scheme;
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Copy to modifiable maps
    _roles = Map.from(widget.workspace.roles ?? {});
    _scheme = Map.from(widget.workspace.scheme ?? {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addRole() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    // Check if name already exists
    if (_roles.containsValue(title)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('المسمى موجود بالفعل')));
      return;
    }

    // Generate ID (simple usage of timestamp + randomish suffix not strictly needed if low volume)
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    setState(() {
      _roles[id] = title;
      _titleController.clear();
    });
  }

  Future<void> _removeRole(String roleId) async {
    // Validation: Check if pending users are assigned to this role
    setState(() => _isLoading = true);

    try {
      final count = await ref
          .read(workspaceRepoProvider)
          .getPendingAssignmentsCountForRole(widget.workspace.id, roleId);

      if (count > 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن حذف الدور: يوجد $count دعوات معلقة لهذا الدور',
            ),
          ),
        );
        return;
      }

      // Also check if any users currently have this role?
      // The requirement was: "cannot delete role if there is users that are pending assignment to that role".
      // Assuming we only check pending for now as requested.
      // Ideally we should also check active users, but following specific request.

      setState(() {
        _roles.remove(roleId);
        // Remove relationships
        _scheme.remove(roleId);
        _scheme.removeWhere((key, value) => value == roleId);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ أثناء التحقق: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateScheme(String roleId, String? managerId) {
    setState(() {
      if (managerId == null) {
        _scheme.remove(roleId);
      } else {
        if (roleId == managerId) return;
        // Check immediate cycle
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
    // Sort roles by name for display? Or insertion order? Map keys are somewhat arbitrary.
    // Let's convert to list of MapEntries for display
    final roleEntries = _roles.entries.toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
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
                // Add Title Section
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
                        icon: const Icon(Icons.add, color: Colors.purple),
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

                            // Available managers: All roles except self
                            final possibleManagers = roleEntries
                                .where((e) => e.key != roleId)
                                .toList();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide.none,
                              ),
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          roleName,
                                          style: const TextStyle(
                                            fontFamily: 'Alexandria',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _removeRole(roleId),
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red.shade400,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
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
                                              color: Colors.grey.shade600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: managerId,
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.grey.shade600,
                                                  size: 20,
                                                ),
                                                hint: Text(
                                                  '—',
                                                  style: TextStyle(
                                                    fontFamily: 'Alexandria',
                                                    fontSize: 14,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                ),
                                                style: TextStyle(
                                                  fontFamily: 'Alexandria',
                                                  fontSize: 14,
                                                  color: Colors.grey.shade800,
                                                ),
                                                items: [
                                                  const DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: null,
                                                    child: Text('— (لا أحد)'),
                                                  ),
                                                  ...possibleManagers.map((m) {
                                                    return DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: m.key,
                                                      child: Text(m.value),
                                                    );
                                                  }),
                                                ],
                                                onChanged: (val) =>
                                                    _updateScheme(roleId, val),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
