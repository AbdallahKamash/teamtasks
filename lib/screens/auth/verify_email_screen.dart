import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/auth/auth_prov.dart';
import 'package:teamtasks/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _verifyCooldownSeconds = 120;
const _verifyLastSentKey = 'verify_last_sent_time';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  int _timerSeconds = 120;
  Timer? _timer;
  Timer? _refreshTimer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCooldown();
      _startRefreshTimer();
    });
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkEmailVerified();
    });
  }

  Future<void> _checkEmailVerified() async {
    final authRepo = ref.read(authRepoProvider);
    await authRepo.reloadUser();
    if (authRepo.currentUser?.emailVerified ?? false) {
      _refreshTimer?.cancel();
      if (mounted) {
        ref.read(routerProvider).go('/home');
      }
    }
  }

  Future<void> _initCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSentMillis = prefs.getInt(_verifyLastSentKey);

    int remaining;

    if (lastSentMillis == null) {
      // First time, send email and start timer
      await _sendEmailVerification(silent: true);
      remaining = _verifyCooldownSeconds;
    } else {
      final lastSent = DateTime.fromMillisecondsSinceEpoch(lastSentMillis);
      final elapsed = DateTime.now().difference(lastSent).inSeconds;

      if (elapsed >= _verifyCooldownSeconds) {
        // Cooldown expired, send email and start timer
        await _sendEmailVerification(silent: true);
        remaining = _verifyCooldownSeconds;
      } else {
        // Cooldown still active, just start timer with remaining time
        remaining = _verifyCooldownSeconds - elapsed;
      }
    }

    if (!mounted) return;

    if (remaining > 0) {
      _startTimer(remaining);
    } else {
      setState(() {
        _timerSeconds = 0;
        _canResend = true;
      });
    }
  }

  void _startTimer(int seconds) {
    _timer?.cancel();

    setState(() {
      _timerSeconds = seconds;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendEmailVerification({bool silent = false}) async {
    try {
      await ref.read(authRepoProvider).sendEmailVerification();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _verifyLastSentKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      if (!mounted) return;
      if (!silent) {}
    } catch (e) {
      if (!mounted) return;
      if (!silent) {}
    }
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;
    await _sendEmailVerification();
    _startTimer(_verifyCooldownSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authRepoProvider).currentUser;
    final email = user?.email ?? '';
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await ref.read(authRepoProvider).signOut();
        if (context.mounted) {
          ref.read(routerProvider).go('/');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 100,
                  color: Colors.purple,
                ),
                const SizedBox(height: 32),
                const Text(
                  'تحقق من بريدك الإلكتروني',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'تم إرسال بريد التحقق إلى $email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: _canResend ? _resendEmail : null,
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _canResend ? Colors.purple : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        _canResend
                            ? 'إعادة الإرسال'
                            : 'إعادة الإرسال خلال $_timerSeconds ثانية',
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          color: _canResend
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    await ref.read(authRepoProvider).signOut();
                    if (!mounted) return;
                    ref.read(routerProvider).go('/');
                  },
                  child: Text(
                    'العودة',
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 16,
                      color: Colors.blueAccent.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
