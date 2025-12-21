import 'package:flutter/material.dart';

enum FieldType { password, email, text }

class MyTextField extends StatefulWidget {
  const MyTextField({
    super.key,
    required this.hintText,
    this.fieldType = .text,
    this.controller,
    this.focusNode,
    this.autofillHints,
  });

  final String hintText;
  final FieldType fieldType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.fieldType == .password;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: widget.fieldType == .text ? .start : .end,
      textDirection: widget.fieldType == .text ? .rtl : .ltr,
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      autofillHints: widget.autofillHints,
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
            color: Colors.grey.shade400,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: .none,
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: .none,
          borderRadius: BorderRadius.circular(10),
        ),
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
    );
  }
}
