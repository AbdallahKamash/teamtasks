import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/router/router.dart';
import 'package:teamtasks/auth/auth_prov.dart';
import 'package:teamtasks/router/auth_transition.dart';
import 'package:teamtasks/auth/auth_errors.dart';
import '../../components/app_toast.dart';
import '../../components/my_textfield.dart';

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

  Set<AuthField> _fieldErrors = {};
  int _errorTick = 0;

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

  FocusNode _focusFor(AuthField field) => switch (field) {
    AuthField.name => displayNameFocus,
    AuthField.email => emailFocus,
    AuthField.password => passwordFocus,
    AuthField.confirmPassword => confirmPasswordFocus,
  };

  /// Highlights + shakes [failure.fields] and shows the failure as a toast.
  void _fail(AuthFailure failure, {ToastType type = ToastType.error}) {
    setState(() {
      _fieldErrors = failure.fields;
      _errorTick++;
    });
    if (failure.fields.isNotEmpty) {
      final first = AuthField.values.firstWhere(failure.fields.contains);
      _focusFor(first).requestFocus();
    }
    Toast.show(failure.title, message: failure.message, type: type);
  }

  void _clearError(AuthField field) {
    if (_fieldErrors.contains(field)) {
      setState(() => _fieldErrors = {..._fieldErrors}..remove(field));
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignup = !_isSignup;
      _fieldErrors = {};
    });
  }

  Future<void> _signUp() async {
    if (_isLoading) return;
    final displayName = displayNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    final missing = [
      if (displayName.isEmpty) AuthField.name,
      if (email.isEmpty) AuthField.email,
      if (password.isEmpty) AuthField.password,
      if (confirmPassword.isEmpty) AuthField.confirmPassword,
    ];
    if (missing.isNotEmpty) {
      return _fail(missingFields(missing), type: ToastType.warning);
    }
    if (displayName.length < 2) {
      return _fail(
        const AuthFailure(
          'الاسم قصير جدًا',
          'أدخل اسمك الكامل ليتعرّف عليك فريقك.',
          {AuthField.name},
        ),
        type: ToastType.warning,
      );
    }
    if (!isValidEmail(email)) return _fail(invalidEmailFailure);
    if (password.length < 6) {
      return _fail(
        const AuthFailure(
          'كلمة المرور قصيرة',
          'يجب أن تتكون من 6 أحرف على الأقل.',
          {AuthField.password},
        ),
        type: ToastType.warning,
      );
    }
    if (password != confirmPassword) {
      return _fail(
        const AuthFailure(
          'كلمتا المرور غير متطابقتين',
          'أعد كتابة كلمة المرور في حقل التأكيد.',
          {AuthField.confirmPassword},
        ),
      );
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _fieldErrors = {};
    });

    try {
      final repo = ref.read(authRepoProvider);
      // Holds the redirect until the profile is written, then swaps to
      // /verify behind the curtain.
      final ran = await ref
          .read(authTransitionProvider)
          .signIn(
            () => repo.signUp(
              email: email,
              password: password,
              displayName: displayName,
            ),
          );
      if (!ran) return; // another auth transition is already running
      Toast.success('تم إنشاء حسابك', message: 'أرسلنا رابط التحقق إلى $email');
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) _fail(describeAuthError(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _login() async {
    if (_isLoading) return;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final missing = [
      if (email.isEmpty) AuthField.email,
      if (password.isEmpty) AuthField.password,
    ];
    if (missing.isNotEmpty) {
      return _fail(missingFields(missing), type: ToastType.warning);
    }
    if (!isValidEmail(email)) return _fail(invalidEmailFailure);

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _fieldErrors = {};
    });

    try {
      final repo = ref.read(authRepoProvider);
      final ran = await ref
          .read(authTransitionProvider)
          .signIn(() => repo.signIn(email: email, password: password));
      if (!ran) return; // another auth transition is already running
      final user = repo.currentUser;
      if (user != null && !user.emailVerified) {
        Toast.info(
          'أكّد بريدك الإلكتروني',
          message: 'افتح رابط التحقق المرسل إلى $email للمتابعة.',
        );
      } else {
        final name = user?.displayName;
        Toast.success(
          'تم تسجيل الدخول',
          message: name != null && name.isNotEmpty
              ? 'أهلًا بعودتك، $name'
              : 'أهلًا بعودتك',
        );
      }
    } catch (e) {
      if (mounted) _fail(describeAuthError(e));
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
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.grey.shade100,
        shadowColor: Colors.grey.shade50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            final router = ref.read(routerProvider);
            router.canPop() ? router.pop() : router.go('/');
          },
        ),
      ),
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
                                      hasError: _fieldErrors.contains(
                                        AuthField.name,
                                      ),
                                      errorTick: _errorTick,
                                      onChanged: (_) =>
                                          _clearError(AuthField.name),
                                      textInputAction: TextInputAction.next,
                                      onSubmitted: (_) =>
                                          emailFocus.requestFocus(),
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
                          hasError: _fieldErrors.contains(AuthField.email),
                          errorTick: _errorTick,
                          onChanged: (_) => _clearError(AuthField.email),
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => passwordFocus.requestFocus(),
                          focusNode: emailFocus,
                          autofillHints: const [AutofillHints.email],
                        ),
                        const SizedBox(height: 16),
                        MyTextField(
                          hintText: 'كلمة المرور',
                          fieldType: .password,
                          controller: passwordController,
                          hasError: _fieldErrors.contains(AuthField.password),
                          errorTick: _errorTick,
                          onChanged: (_) => _clearError(AuthField.password),
                          textInputAction: _isSignup
                              ? TextInputAction.next
                              : TextInputAction.done,
                          onSubmitted: (_) => _isSignup
                              ? confirmPasswordFocus.requestFocus()
                              : _login(),
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
                                      hasError: _fieldErrors.contains(
                                        AuthField.confirmPassword,
                                      ),
                                      errorTick: _errorTick,
                                      onChanged: (_) => _clearError(
                                        AuthField.confirmPassword,
                                      ),
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _signUp(),
                                      focusNode: confirmPasswordFocus,
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
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
                          ref.read(routerProvider).push('/forgot-password');
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
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleMode,
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
