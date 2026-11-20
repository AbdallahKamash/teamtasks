import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:teamtasks/auth/auth_errors.dart';
import 'package:teamtasks/auth/auth_prov.dart';
import 'package:teamtasks/components/app_toast.dart';
import 'package:teamtasks/router/auth_curtain.dart';
import 'package:teamtasks/router/motion.dart';
import 'package:teamtasks/router/router.dart';

/// Owns every auth-boundary navigation (login, sign-up, verify → home,
/// logout, verify-back). UI code never calls `go('/')` / `go('/home')` for
/// auth; it calls this instead.
///
/// Each boundary runs behind [AuthCurtain]: cover → swap the whole stack
/// instantly → wait until the old routes are disposed → reveal. Authenticated
/// screens are therefore never visible or reachable after logout, and they
/// are torn down while the credentials are still valid.
final authTransitionProvider = Provider<AuthTransition>(AuthTransition.new);

/// The app-level ScaffoldMessenger (sits above the Navigator), so auth swaps
/// can drop SnackBars queued by screens that no longer exist.
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AuthTransition {
  AuthTransition(this._ref);

  final Ref _ref;
  bool _busy = false;
  bool _hold = false;
  bool _signingOut = false;

  /// True while sign-in/sign-up credentials are in flight: the redirect keeps
  /// the user on the public screens until the curtain is up.
  bool get holdsAuthRedirect => _hold;

  /// True during logout: the redirect pins every navigation to `/`.
  bool get isSigningOut => _signingOut;

  GoRouter get _router => _ref.read(routerProvider);

  /// Sign-in and sign-up. The redirect is held while [credentials] runs.
  /// Rethrows credential errors so the caller can show them.
  ///
  /// Returns false if it did not run because another boundary transition is
  /// in progress; callers must not treat that as success.
  Future<bool> signIn(Future<void> Function() credentials) async {
    if (_busy) return false;
    _busy = true;
    _hold = true;
    try {
      await credentials();
    } catch (_) {
      _hold = false;
      _busy = false;
      // Failed sign-in: no-op. Partial sign-up (user exists): → /verify.
      _router.refresh();
      rethrow;
    }
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      await AuthCurtain.cover();
      _clearTransientUi();
      _hold = false;
      _router.refresh(); // redirect → /home or /verify, instant under curtain
      await _settle((p) => p == '/home' || p == '/verify');
    } finally {
      _hold = false;
      await AuthCurtain.reveal(CurtainReveal.enterApp);
      _busy = false;
    }
    return true;
  }

  /// /verify → /home after `reloadUser()` reports the email as verified.
  ///
  /// Returns true only if the app actually arrived at /home; on false the
  /// caller is still on /verify and should resume what it was doing.
  Future<bool> enterApp() async {
    if (_busy) return false;
    _busy = true;
    var arrived = false;
    try {
      await AuthCurtain.cover();
      _clearTransientUi();
      _router.refresh(); // reload() emits no authStateChanges event
      arrived = await _settle((p) => p == '/home');
    } finally {
      await AuthCurtain.reveal(CurtainReveal.enterApp);
      _busy = false;
    }
    return arrived;
  }

  /// Logout and verify-back.
  ///
  /// Returns true once signed out. Returns false if it did not run (another
  /// transition is in progress) or if signing out failed (the user is put
  /// back where they were and shown an error).
  Future<bool> signOut() async {
    if (_busy) return false;
    _busy = true;
    _signingOut = true;
    Object? failure;
    try {
      Toast.dismissAll();
      FocusManager.instance.primaryFocus?.unfocus();
      await AuthCurtain.cover();
      _clearTransientUi();
      _router.go('/'); // the only navigation; the gate keeps it at '/'
      await _settle((p) => p == '/'); // authenticated routes disposed
      await _ref.read(authRepoProvider).signOut();
    } catch (e) {
      failure = e;
    } finally {
      _signingOut = false;
      // Signed out: no-op. signOut failed: '/' → '/home' under the curtain.
      _router.refresh();
      await _settle(null);
      await AuthCurtain.reveal(
        failure == null ? CurtainReveal.exitApp : CurtainReveal.enterApp,
      );
      _busy = false;
    }
    if (failure != null) {
      final f = describeAuthError(failure);
      Toast.error(f.title, message: f.message);
      return false;
    }
    return true;
  }

  /// Before a stack swap: closes dialogs, pickers and menus (pageless routes)
  /// and drops SnackBars/banners queued by the outgoing screens.
  void _clearTransientUi() {
    _router.routerDelegate.navigatorKey.currentState?.popUntil(
      (Route<dynamic> r) => r is PageRoute,
    );
    rootMessengerKey.currentState
      ?..clearSnackBars()
      ..clearMaterialBanners();
  }

  /// Waits until the router reaches a location matching [arrived], then until
  /// the Navigator has applied the pages and disposed the removed routes.
  /// Returns whether the location was reached (false on timeout).
  Future<bool> _settle(bool Function(String path)? arrived) async {
    final GoRouterDelegate delegate = _router.routerDelegate;
    bool done() =>
        arrived == null || arrived(delegate.currentConfiguration.uri.path);
    if (!done()) {
      final Completer<void> c = Completer<void>();
      void listener() {
        if (done() && !c.isCompleted) c.complete();
      }

      delegate.addListener(listener);
      try {
        await c.future.timeout(AppMotion.settleTimeout, onTimeout: () {});
      } finally {
        delegate.removeListener(listener);
      }
    }
    // 1: Navigator applied the pages; the zero-duration root went idle.
    await WidgetsBinding.instance.endOfFrame;
    // 2: routes in `removing` disposed, their widgets unmounted.
    await WidgetsBinding.instance.endOfFrame;
    // Riverpod's Timer(Duration.zero) autoDispose cancels their streams.
    await Future<void>.delayed(Duration.zero);
    return done();
  }
}
