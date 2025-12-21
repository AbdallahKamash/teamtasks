import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/workspace_model.dart';
import '../../workspace/workspace_prov.dart';

class EditWorkspaceScreen extends ConsumerStatefulWidget {
  final WorkspaceModel workspace;

  const EditWorkspaceScreen({required this.workspace, super.key});

  @override
  ConsumerState<EditWorkspaceScreen> createState() =>
      _EditWorkspaceScreenState();
}

class _EditWorkspaceScreenState extends ConsumerState<EditWorkspaceScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _logoUrlController;
  late Color _selectedColor;
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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workspace.name);
    _descriptionController = TextEditingController(
      text: widget.workspace.description,
    );
    _logoUrlController = TextEditingController(text: widget.workspace.logoUrl);
    _selectedColor = _hexToColor(widget.workspace.color);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  Future<void> _saveChanges() async {
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
      final updatedWorkspace = widget.workspace.copyWith(
        name: name,
        color: _colorToHex(_selectedColor),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        logoUrl: _logoUrlController.text.trim().isEmpty
            ? null
            : _logoUrlController.text.trim(),
      );

      await ref.read(workspaceRepoProvider).updateWorkspace(updatedWorkspace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تحديث مساحة العمل بنجاح',
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
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تعديل مساحة العمل',
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
              _buildLabel('اسم مساحة العمل'),
              const SizedBox(height: 8),
              _buildTextField(_nameController, hint: 'مثلاً: مشروعي الجديد'),
              const SizedBox(height: 24),

              _buildLabel('وصف مساحة العمل (اختياري)'),
              const SizedBox(height: 8),
              _buildTextField(
                _descriptionController,
                hint: 'وصف قصير...',
                maxLines: 3,
                maxLength: 250,
              ),
              const SizedBox(height: 24),

              _buildLabel('رابط الشعار (اختياري)'),
              const SizedBox(height: 8),
              _buildTextField(
                _logoUrlController,
                hint: 'https://example.com/logo.png',
              ),
              const SizedBox(height: 24),

              _buildLabel('لون مساحة العمل'),
              const SizedBox(height: 12),
              _buildColorPicker(),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
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

  Widget _buildTextField(
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(fontFamily: 'Alexandria', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
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
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ..._presetColors.take(7).map((color) {
          final isSelected = _selectedColor == color;
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.black, width: 2)
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
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          );
        }),
        GestureDetector(
          onTap: _showColorPickerDialog,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: const SweepGradient(
                colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.indigo,
                  Colors.purple,
                  Colors.red,
                ],
              ),
              shape: BoxShape.circle,
              border: !_presetColors.contains(_selectedColor)
                  ? Border.all(color: Colors.black, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: !_presetColors.contains(_selectedColor)
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : const Icon(Icons.colorize, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        Color pickedColor = _selectedColor;
        return AlertDialog(
          title: const Text(
            'اختر لوناً',
            style: TextStyle(fontFamily: 'Alexandria'),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (color) => pickedColor = color,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
              labelTypes: const [],
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Alexandria'),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'تحقق',
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                setState(() => _selectedColor = pickedColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
