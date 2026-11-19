import 'package:firebase_auth/firebase_auth.dart';

enum AuthField { name, email, password, confirmPassword }

extension AuthFieldLabel on AuthField {
  String get label => switch (this) {
    AuthField.name => 'الاسم',
    AuthField.email => 'البريد الإلكتروني',
    AuthField.password => 'كلمة المرور',
    AuthField.confirmPassword => 'تأكيد كلمة المرور',
  };
}

/// A user-facing description of an auth failure, plus which fields to flag.
class AuthFailure {
  const AuthFailure(this.title, this.message, [this.fields = const {}]);

  final String title;
  final String message;
  final Set<AuthField> fields;
}

final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

bool isValidEmail(String email) => _emailRegex.hasMatch(email);

/// Toast copy for one or more empty required fields (in the order given).
AuthFailure missingFields(List<AuthField> fields) {
  if (fields.length == 1) {
    return AuthFailure(
      'حقل مطلوب',
      'أدخل ${fields.first.label} للمتابعة.',
      fields.toSet(),
    );
  }
  return AuthFailure(
    'حقول ناقصة',
    'أكمل: ${fields.map((f) => f.label).join('، ')}.',
    fields.toSet(),
  );
}

const invalidEmailFailure = AuthFailure(
  'بريد إلكتروني غير صالح',
  'تأكد من كتابته بشكل صحيح، مثل name@example.com',
  {AuthField.email},
);

AuthFailure describeAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
      case 'missing-email':
        return invalidEmailFailure;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return const AuthFailure(
          'بيانات الدخول غير صحيحة',
          'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
          {AuthField.email, AuthField.password},
        );
      case 'user-disabled':
        return const AuthFailure(
          'الحساب موقوف',
          'تم إيقاف هذا الحساب. تواصل مع الدعم للمساعدة.',
          {AuthField.email},
        );
      case 'email-already-in-use':
        return const AuthFailure(
          'البريد مستخدم بالفعل',
          'يوجد حساب بهذا البريد. جرّب تسجيل الدخول بدلًا من ذلك.',
          {AuthField.email},
        );
      case 'weak-password':
        return const AuthFailure(
          'كلمة مرور ضعيفة',
          'استخدم 6 أحرف على الأقل مع مزيج من الحروف والأرقام.',
          {AuthField.password},
        );
      case 'too-many-requests':
        return const AuthFailure(
          'محاولات كثيرة',
          'تم إيقاف المحاولات مؤقتًا. انتظر قليلًا ثم حاول مجددًا.',
        );
      case 'network-request-failed':
        return const AuthFailure(
          'لا يوجد اتصال',
          'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          'غير متاح حاليًا',
          'تسجيل الدخول بالبريد الإلكتروني غير مفعّل.',
        );
    }
  }

  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return const AuthFailure(
        'تعذّر الوصول إلى بياناتك',
        'ليست لديك صلاحية الوصول إلى قاعدة البيانات.',
      );
    }
    if (error.code == 'unavailable') {
      return const AuthFailure(
        'الخدمة غير متاحة',
        'تعذّر الاتصال بالخادم. حاول مرة أخرى بعد قليل.',
      );
    }
  }

  return const AuthFailure('حدث خطأ غير متوقع', 'حاول مرة أخرى بعد قليل.');
}
