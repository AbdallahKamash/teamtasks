import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/auth/auth_prov.dart';
import 'package:teamtasks/router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final displayNameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  bool _isLoading = false;

  bool _isSignup = false;

  @override
  void dispose() {
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    displayNameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final displayName = displayNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (displayName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return;
    }

    if (password != confirmPassword) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authRepoProvider)
          .signUp(email: email, password: password, displayName: displayName);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepoProvider).signIn(email: email, password: password);
      if (!mounted) return;
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.read(routerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutofillGroup(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSignup ? 'إنشاء حساب   ' : 'مرحبًا بعودتك ',
                          style: const TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 40,
                            fontVariations: [FontVariation('wght', 700)],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isSignup
                              ? 'أنشئ حسابك لحفظ حالتك في السحابة'
                              : 'سجّل الدخول للمتابعة',
                          style: const TextStyle(
                            fontFamily: 'Alexandria',
                            color: Colors.grey,
                            fontSize: 16,
                            fontVariations: [FontVariation('wght', 400)],
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isSignup ? 1 : 0,
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 400),
                              offset: _isSignup
                                  ? Offset.zero
                                  : const Offset(0, -0.1),
                              curve: Curves.easeOutCubic,
                              child: _isSignup
                                  ? MyTextField(
                                      hintText: 'الاسم بالكامل',
                                      controller: displayNameController,
                                      focusNode: displayNameFocus,
                                      autofillHints: const [AutofillHints.name],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        MyTextField(
                          hintText: 'البريد الإلكتروني',
                          fieldType: .email,
                          controller: emailController,
                          focusNode: emailFocus,
                          autofillHints: const [AutofillHints.email],
                        ),
                        const SizedBox(height: 16),
                        MyTextField(
                          hintText: 'كلمة المرور',
                          fieldType: .password,
                          controller: passwordController,
                          focusNode: passwordFocus,
                          autofillHints: const [AutofillHints.password],
                        ),
                        const SizedBox(height: 16),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isSignup ? 1 : 0,
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 400),
                              offset: _isSignup
                                  ? Offset.zero
                                  : const Offset(0, -0.1),
                              curve: Curves.easeOutCubic,
                              child: _isSignup
                                  ? MyTextField(
                                      hintText: 'تأكيد كلمة المرور',
                                      fieldType: .password,
                                      controller: confirmPasswordController,
                                      focusNode: confirmPasswordFocus,
                                      autofillHints: const [AutofillHints.password],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          router.push('/forgot-password');
                        },
                        child: Text(
                          'نسيت كلمة السر؟',
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontWeight: .bold,
                            fontSize: 12,
                            color: Colors.blueAccent.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _isSignup ? _signUp() : _login();
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5,

                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  _isSignup ? 'إنشاء حساب' : 'تسجيل الدخول',
                                  key: ValueKey(_isSignup),
                                  style: const TextStyle(
                                    fontFamily: 'Alexandria',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'لديك ${_isSignup ? '' : 'ليس '}حساب؟  ',
                        style: TextStyle(fontFamily: 'Alexandria', fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSignup = !_isSignup;
                          });
                        },
                        child: Text(
                          _isSignup ? 'سجل دخولك' : 'أنشئ حسابك',
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontWeight: .bold,
                            fontSize: 12,
                            color: Colors.blueAccent.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
