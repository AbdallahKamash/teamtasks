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
    // Control the speed here (e.g., 300ms is standard)
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return Directionality(
        textDirection: dir,
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: dir == .ltr
                    ? Offset(1.0, 0.0)
                    : Offset(-1.0, 0.0), // Starts off-screen to the right
                end: Offset.zero, // Ends at the center
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve:
                      Curves.easeInOutCubic, // Smooth acceleration/deceleration
                ),
              ),
          child: child,
        ),
      );
    },
  );
}
