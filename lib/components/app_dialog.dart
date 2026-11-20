import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoDialogRoute;
import 'package:material_ui/material_ui.dart';

/// iOS: native alert presentation (spring, 1.3→1.0 scale + fade, fade-only
/// exit, 20% barrier). Android: Material DialogRoute (150 ms fade, black54).
/// Dialog content is unchanged on both.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final TargetPlatform p = Theme.of(context).platform;
  if (p != TargetPlatform.iOS && p != TargetPlatform.macOS) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }
  final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: navigator.context,
  );
  return navigator.push<T>(
    CupertinoDialogRoute<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) =>
          themes.wrap(SafeArea(child: Builder(builder: builder))),
    ),
  );
}
