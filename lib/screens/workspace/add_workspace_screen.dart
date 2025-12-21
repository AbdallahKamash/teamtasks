import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_prov.dart';
import '../../models/workspace_model.dart';
import '../../workspace/workspace_prov.dart';

class AddWorkspaceScreen extends ConsumerStatefulWidget {
  const AddWorkspaceScreen({super.key});

  @override
  ConsumerState<AddWorkspaceScreen> createState() =>
      _AddWorkspaceScreenState();
}

class _AddWorkspaceScreenState
    extends ConsumerState<AddWorkspaceScreen> {
  final TextEditingController _nameController = TextEditingController();

  Color _selectedColor = Colors.purple;
  bool _isLoading = false;

  final List<Color> _presetColors = [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  Future<void> _saveWorkspace() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال اسم مساحة العمل',
            style: TextStyle(fontFamily: 'Alexandria'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final workspace = WorkspaceModel(
        id: '',
        name: name,
        color: _colorToHex(_selectedColor),
        creatorId: user.uid,
        createdAt: DateTime.now(),
      );

      final workspaceId = await ref
          .read(workspaceRepoProvider)
          .createWorkspace(workspace);

      if (!mounted) return;

      ref
          .read(selectedWorkspaceIdProvider.notifier)
          .select(workspaceId);

      _nameController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إنشاء مساحة العمل بنجاح',
            style: TextStyle(fontFamily: 'Alexandria'),
          ),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطأ: $e',
            style: const TextStyle(fontFamily: 'Alexandria'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'إضافة مساحة عمل',
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
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تفاصيل مساحة العمل',
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('اسم مساحة العمل'),
              const SizedBox(height: 8),

              TextField(
                controller: _nameController,
                style: const TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'مثلاً: مشروعي الجديد',
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

              const SizedBox(height: 24),
              _buildLabel('لون مساحة العمل'),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _presetColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColor = color),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                          color: Colors.black,
                          width: 2,
                        )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveWorkspace,
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
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'حفظ مساحة العمل',
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
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Alexandria',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }
}