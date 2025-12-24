import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage buildPageWithTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  required TextDirection dir,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return Directionality(
        textDirection: .rtl,
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: dir == .ltr
                    ? Offset(1.0, 0.0)
                    : Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve:
                      Curves.easeInOutCirc,
                ),
              ),
          child: child,
        ),
      );
    },
  );
}
