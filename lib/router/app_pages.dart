import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoPage;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'auth_curtain.dart';
import 'motion.dart';

bool _isCupertino(BuildContext context) {
  final TargetPlatform p = Theme.of(context).platform;
  return p == TargetPlatform.iOS || p == TargetPlatform.macOS;
}

/// Standard hierarchical page: native iOS push (parallax, dim, edge swipe)
/// or the theme's Android transition (Zoom).
Page<void> pushPage(BuildContext context, GoRouterState state, Widget child) {
  return _isCupertino(context)
      ? CupertinoPage<void>(
          key: state.pageKey,
          name: state.matchedLocation,
          child: child,
        )
      : MaterialPage<void>(
          key: state.pageKey,
          name: state.matchedLocation,
          child: child,
        );
}

enum RootEntrance { forward, backward }

/// Auth-boundary root ('/', '/home', '/verify'). Opaque backdrop from the
/// first frame; content fades + scales in. Zero duration while the curtain
/// covers the screen (orchestrated swaps).
Page<void> rootPage(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  required RootEntrance entrance,
  Color backdrop = AppMotion.surface,
}) {
  final bool reduce = MediaQuery.disableAnimationsOf(context);
  final Duration duration = AuthCurtain.isCovered
      ? Duration.zero
      : (reduce ? AppMotion.rootEnterReduced : AppMotion.rootEnter);
  final double scaleFrom = reduce
      ? 1.0
      : (entrance == RootEntrance.forward
            ? AppMotion.enterScaleFrom
            : AppMotion.exitScaleFrom);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.matchedLocation,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ColoredBox(
        color: backdrop,
        child: FadeTransition(
          opacity: animation.drive(CurveTween(curve: AppMotion.rootFade)),
          child: ScaleTransition(
            scale: animation.drive(
              Tween<double>(
                begin: scaleFrom,
                end: 1.0,
              ).chain(CurveTween(curve: AppMotion.rootScale)),
            ),
            child: child,
          ),
        ),
      );
    },
  );
}
