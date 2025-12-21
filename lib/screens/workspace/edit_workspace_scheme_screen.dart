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
  late List<String> _titles;
  // Scheme maps a Role -> Manager Role.
  // Key: The role that reports. Value: The role they report to.
  late Map<String, String> _scheme;
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titles = List.from(widget.workspace.titles ?? []);
    _scheme = Map.from(widget.workspace.scheme ?? {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addTitle() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    if (_titles.contains(title)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('المسمى موجود بالفعل')));
      return;
    }
    setState(() {
      _titles.add(title);
      _titleController.clear();
    });
  }

  void _removeTitle(String title) {
    setState(() {
      _titles.remove(title);
      // Remove any scheme entries involving this title
      _scheme.remove(title);
      _scheme.removeWhere((key, value) => value == title);
    });
  }

  void _updateScheme(String role, String? manager) {
    setState(() {
      if (manager == null) {
        _scheme.remove(role);
      } else {
        // Prevent simple cycles (A -> B, B -> A) and self-reference
        if (role == manager) return;
        if (_scheme[manager] == role) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا يمكن إنشاء حلقة دائرية')),
          );
          return;
        }
        // Deep cycle check could be added here but simple checks suffice for now
        _scheme[role] = manager;
      }
    });
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedWorkspace = widget.workspace.copyWith(
        titles: _titles,
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
                        onPressed: _addTitle,
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
                  child: _titles.isEmpty
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
                          itemCount: _titles.length,
                          padding: const EdgeInsets.only(bottom: 80),
                          itemBuilder: (context, index) {
                            final role = _titles[index];
                            final manager = _scheme[role];

                            // Available managers: All titles except self
                            final possibleManagers = _titles
                                .where((t) => t != role)
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
                                          role,
                                          style: const TextStyle(
                                            fontFamily: 'Alexandria',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _removeTitle(role),
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
                                                value: manager,
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
                                                    >(value: m, child: Text(m));
                                                  }),
                                                ],
                                                onChanged: (val) =>
                                                    _updateScheme(role, val),
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
