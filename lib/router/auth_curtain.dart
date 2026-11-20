import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'motion.dart';

enum CurtainReveal { enterApp, exitApp }

abstract final class AuthCurtain {
  static _AuthCurtainHostState? _host;

  static bool get isCovered => _host?._c.isCompleted ?? false;

  static Future<void> cover() => _host?._cover() ?? Future<void>.value();

  static Future<void> reveal(CurtainReveal kind) =>
      _host?._reveal(kind) ?? Future<void>.value();
}

class AuthCurtainHost extends StatefulWidget {
  const AuthCurtainHost({super.key, required this.child});

  final Widget child;

  @override
  State<AuthCurtainHost> createState() => _AuthCurtainHostState();
}

class _AuthCurtainHostState extends State<AuthCurtainHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.curtainCover,
    reverseDuration: AppMotion.curtainReveal,
  );
  bool _blocking = false;
  bool _spinner = false;
  double _scaleFrom = 1.0;
  Timer? _spinnerTimer;

  bool get _reduce => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void initState() {
    super.initState();
    AuthCurtain._host = this;
  }

  @override
  void dispose() {
    if (identical(AuthCurtain._host, this)) AuthCurtain._host = null;
    _spinnerTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  Future<void> _cover() async {
    _spinnerTimer?.cancel();
    setState(() {
      _blocking = true;
      _scaleFrom = 1.0;
    });
    _spinnerTimer = Timer(AppMotion.curtainSpinnerDelay, () {
      if (mounted && _blocking) setState(() => _spinner = true);
    });
    if (_reduce) {
      _c.value = 1;
      return;
    }
    try {
      await _c.animateTo(1, curve: AppMotion.curtainCoverCurve).orCancel;
    } on TickerCanceled {
      // Host disposed mid-cover.
    }
  }

  Future<void> _reveal(CurtainReveal kind) async {
    _spinnerTimer?.cancel();
    // Keep absorbing input until the reveal finishes: a tap during the fade
    // would otherwise reach a screen whose transition is still settling.
    setState(() {
      _spinner = false;
      _scaleFrom = kind == CurtainReveal.enterApp
          ? AppMotion.enterScaleFrom
          : AppMotion.exitScaleFrom;
    });
    if (_reduce) {
      _c.value = 0;
    } else {
      try {
        await _c.animateBack(0, curve: AppMotion.curtainRevealCurve).orCancel;
      } on TickerCanceled {
        return;
      }
    }
    if (mounted) {
      setState(() {
        _blocking = false;
        _scaleFrom = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget curtain = IgnorePointer(
      ignoring: !_blocking, // pass-through while revealing
      child: AbsorbPointer(
        // swallow every tap while covering
        child: BlockSemantics(
          blocking: _blocking,
          child: FadeTransition(
            opacity: _c,
            child: ColoredBox(
              color: AppMotion.surface,
              child: _spinner
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        ScaleTransition(
          scale: _c.drive(Tween<double>(begin: 1.0, end: _scaleFrom)),
          child: widget.child,
        ),
        AnimatedBuilder(
          animation: _c,
          builder: (context, child) =>
              Offstage(offstage: _c.isDismissed && !_blocking, child: child),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: curtain,
          ),
        ),
      ],
    );
  }
}
