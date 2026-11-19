import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../router/router.dart';

class DeleteConfirmationDialog extends ConsumerStatefulWidget {
  final String workspaceName;

  const DeleteConfirmationDialog({super.key, required this.workspaceName});

  @override
  ConsumerState<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState
    extends ConsumerState<DeleteConfirmationDialog> {
  late TextEditingController _controller;
  bool _isMatch = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_checkMatch);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkMatch() {
    setState(() {
      _isMatch = _controller.text.trim() == widget.workspaceName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'هل أنت متأكد؟',
        style: TextStyle(fontFamily: 'Alexandria', fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'هذا الإجراء لا يمكن التراجع عنه. سيتم حذف مساحة العمل وكل البيانات المرتبطة بها نهائياً.',
            style: TextStyle(fontFamily: 'Alexandria'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'للتحقق، يرجى كتابة "${widget.workspaceName}" أدناه:',
            style: const TextStyle(
              fontFamily: 'Alexandria',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.workspaceName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            style: const TextStyle(fontFamily: 'Alexandria'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => ref.read(routerProvider).pop(false),
          child: const Text(
            'إلغاء',
            style: TextStyle(fontFamily: 'Alexandria', color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: _isMatch ? () => ref.read(routerProvider).pop(true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            disabledBackgroundColor: Colors.red.withValues(alpha: 0.3),
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'حذف نهائي',
            style: TextStyle(fontFamily: 'Alexandria'),
          ),
        ),
      ],
    );
  }
}
