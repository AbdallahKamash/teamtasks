import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/auth/auth_prov.dart';
import 'package:teamtasks/router/router.dart';

import 'package:teamtasks/auth/auth_errors.dart';
import '../../components/app_toast.dart';
import '../../components/my_textfield.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final emailFocus = FocusNode();
  bool _isLoading = false;
  bool _emailError = false;
  int _errorTick = 0;

  void _fail(AuthFailure failure, {ToastType type = ToastType.error}) {
    setState(() {
      _emailError = failure.fields.contains(AuthField.email);
      _errorTick++;
    });
    if (_emailError) emailFocus.requestFocus();
    Toast.show(failure.title, message: failure.message, type: type);
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      return _fail(missingFields([AuthField.email]), type: ToastType.warning);
    }
    if (!isValidEmail(email)) return _fail(invalidEmailFailure);

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _emailError = false;
    });

    try {
      await ref.read(authRepoProvider).sendPasswordResetEmail(email);
      Toast.success(
        'تم إرسال الرابط',
        message: 'تحقق من صندوق الوارد في $email',
      );
      if (!mounted) return;
      ref.read(routerProvider).pop();
    } catch (e) {
      if (!mounted) return;
      _fail(describeAuthError(e));
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
          onPressed: () => ref.read(routerProvider).pop(),
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'نسيت كلمة السر؟',
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 32,
                      fontVariations: [FontVariation('wght', 700)],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور الخاصة بك.',
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      color: Colors.grey,
                      fontSize: 16,
                      fontVariations: [FontVariation('wght', 400)],
                    ),
                  ),
                  const SizedBox(height: 32),
                  MyTextField(
                    hintText: 'البريد الإلكتروني',
                    fieldType: .email,
                    controller: emailController,
                    focusNode: emailFocus,
                    autofillHints: const [AutofillHints.email],
                    hasError: _emailError,
                    errorTick: _errorTick,
                    onChanged: (_) {
                      if (_emailError) setState(() => _emailError = false);
                    },
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _resetPassword(),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _isLoading ? null : _resetPassword,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              )
                            : const Text(
                                'إرسال الرابط',
                                style: TextStyle(
                                  fontFamily: 'Alexandria',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => ref.read(routerProvider).pop(),
                      child: Text(
                        'العودة لتسجيل الدخول',
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blueAccent.shade700,
                        ),
                      ),
                    ),
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
