import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

enum FieldType { password, email, text }

class MyTextField extends StatefulWidget {
  const MyTextField({
    super.key,
    required this.hintText,
    this.fieldType = .text,
    this.controller,
    this.focusNode,
    this.autofillHints,
    this.hasError = false,
    this.errorTick = 0,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
  });

  final String hintText;
  final FieldType fieldType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  /// Tints the field red.
  final bool hasError;

  /// Bump this while [hasError] is true to shake the field again.
  final int errorTick;

  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField>
    with SingleTickerProviderStateMixin {
  late bool _obscureText;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  );

  @override
  void initState() {
    super.initState();
    _obscureText = widget.fieldType == .password;
  }

  @override
  void didUpdateWidget(covariant MyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError &&
        (!oldWidget.hasError || widget.errorTick != oldWidget.errorTick)) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Colors.red.shade400;
    final border = OutlineInputBorder(
      borderSide: widget.hasError
          ? BorderSide(color: errorColor.withValues(alpha: 0.7), width: 1.4)
          : BorderSide.none,
      borderRadius: BorderRadius.circular(10),
    );

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final t = _shake.value;
        final dx = math.sin(t * math.pi * 6) * 9 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: TextFormField(
        textAlign: widget.fieldType == .text ? .start : .end,
        textDirection: widget.fieldType == .text ? .rtl : .ltr,
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: _obscureText,
        autofillHints: widget.autofillHints,
        onChanged: widget.onChanged,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        autocorrect: widget.fieldType == .text,
        cursorColor: Colors.blue[900],
        cursorHeight: 24,
        keyboardType: widget.fieldType == .password
            ? TextInputType.visiblePassword
            : widget.fieldType == .email
            ? TextInputType.emailAddress
            : .text,
        style: const TextStyle(
          fontFamily: 'Alexandria',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hint: Text(
            widget.hintText,
            style: TextStyle(
              fontFamily: 'Alexandria',
              fontSize: 16,
              color: widget.hasError
                  ? errorColor.withValues(alpha: 0.7)
                  : Colors.grey.shade400,
            ),
          ),
          filled: true,
          fillColor: widget.hasError ? const Color(0xFFFFF4F4) : Colors.white,
          enabledBorder: border,
          focusedBorder: border,
          suffixIcon: widget.fieldType == .password
              ? IconButton(
                  icon: Icon(
                    color: Colors.grey.shade400,
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                )
              : null,
        ),
        validator: (val) =>
            val == null || val.isEmpty ? 'ادخل ${widget.hintText}' : null,
      ),
    );
  }
}
