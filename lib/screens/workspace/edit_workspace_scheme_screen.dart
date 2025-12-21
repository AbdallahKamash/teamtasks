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
      appBar: AppBar(
        title: const Text(
          'تعديل الهيكل التنظيمي',
          style: TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _save,
              icon: const Icon(Icons.check),
              tooltip: 'حفظ',
            ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add Title Section
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'أدخل المسمى الوظيفي (مثال: مدير)',
                        hintStyle: const TextStyle(fontFamily: 'Alexandria'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Alexandria'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addTitle,
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.purple,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'المسميات والعلاقات',
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _titles.isEmpty
                    ? Center(
                        child: Text(
                          'لا يوجد مسميات بعد',
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _titles.length,
                        itemBuilder: (context, index) {
                          final role = _titles[index];
                          final manager = _scheme[role];

                          // Available managers: All titles except self
                          final possibleManagers = _titles
                              .where((t) => t != role)
                              .toList();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
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
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        'يتبع لـ: ',
                                        style: TextStyle(
                                          fontFamily: 'Alexandria',
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            value: manager,
                                            hint: const Text(
                                              '—', // No manager
                                              style: TextStyle(
                                                fontFamily: 'Alexandria',
                                              ),
                                            ),
                                            items: [
                                              const DropdownMenuItem<String>(
                                                value: null,
                                                child: Text(
                                                  '— (لا أحد)',
                                                  style: TextStyle(
                                                    fontFamily: 'Alexandria',
                                                  ),
                                                ),
                                              ),
                                              ...possibleManagers.map((m) {
                                                return DropdownMenuItem<String>(
                                                  value: m,
                                                  child: Text(
                                                    m,
                                                    style: const TextStyle(
                                                      fontFamily: 'Alexandria',
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                            onChanged: (val) =>
                                                _updateScheme(role, val),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
