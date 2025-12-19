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
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  bool _isLoading = false;

  bool _isSignup = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('جميع الحقول مطلوبة')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authRepoProvider)
          .signUp(email: email, password: password, displayName: name);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل إنشاء الحساب: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepoProvider).signIn(email: email, password: password);
      if (!mounted) return;
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.read(routerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
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
                    offset: _isSignup ? Offset.zero : const Offset(0, -0.1),
                    curve: Curves.easeOutCubic,
                    child: _isSignup
                        ? MyTextField(
                            hintText: 'الاسم بالكامل',
                            controller: nameController,
                            focusNode: nameFocus,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MyTextField(
                hintText: 'البريد الإلكتروني',
                controller: emailController,
                focusNode: emailFocus,
              ),
              const SizedBox(height: 16),
              MyTextField(
                hintText: 'كلمة المرور',
                isPassword: true,
                controller: passwordController,
                focusNode: passwordFocus,
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
                    offset: _isSignup ? Offset.zero : const Offset(0, -0.1),
                    curve: Curves.easeOutCubic,
                    child: _isSignup
                        ? MyTextField(
                            hintText: 'تأكيد كلمة المرور',
                            isPassword: true,
                            controller: confirmPasswordController,
                            focusNode: confirmPasswordFocus,
                          )
                        : const SizedBox.shrink(),
                  ),
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
    );
  }
}

class MyTextField extends StatefulWidget {
  const MyTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.focusNode,
  });

  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      cursorColor: Colors.blue[900],
      cursorHeight: 24,
      keyboardType: widget.isPassword
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
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
        suffixIcon: widget.isPassword
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
