import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

/// In-app toasts styled like the app's own cards, sliding in from the top.
///
/// Mount [AppToastHost] once (in `MaterialApp.builder`), then call
/// `Toast.success(...)`, `Toast.error(...)`, etc. from anywhere — no
/// BuildContext needed, and toasts survive route changes.
enum ToastType { success, error, warning, info }

extension _ToastStyle on ToastType {
  // Same palette the app uses for notification and task states.
  Color get color => switch (this) {
    ToastType.success => Colors.green,
    ToastType.error => Colors.red,
    ToastType.warning => Colors.orange,
    ToastType.info => Colors.purple,
  };

  IconData get icon => switch (this) {
    ToastType.success => Icons.check_circle_rounded,
    ToastType.error => Icons.cancel_rounded,
    ToastType.warning => Icons.error_rounded,
    ToastType.info => Icons.notifications_rounded,
  };

  Duration get defaultDuration => switch (this) {
    ToastType.success => const Duration(milliseconds: 2800),
    ToastType.error => const Duration(milliseconds: 4200),
    ToastType.warning => const Duration(milliseconds: 3400),
    ToastType.info => const Duration(milliseconds: 3200),
  };

  void haptic() {
    switch (this) {
      case ToastType.error:
        HapticFeedback.heavyImpact();
      case ToastType.warning:
        HapticFeedback.mediumImpact();
      case ToastType.success:
      case ToastType.info:
        HapticFeedback.lightImpact();
    }
  }
}

class Toast {
  Toast._();

  static final _ToastController _controller = _ToastController();

  static void show(
    String title, {
    String? message,
    ToastType type = ToastType.info,
    Duration? duration,
  }) {
    _controller.add(title, message, type, duration ?? type.defaultDuration);
  }

  static void success(String title, {String? message, Duration? duration}) =>
      show(
        title,
        message: message,
        type: ToastType.success,
        duration: duration,
      );

  static void error(String title, {String? message, Duration? duration}) =>
      show(title, message: message, type: ToastType.error, duration: duration);

  static void warning(String title, {String? message, Duration? duration}) =>
      show(
        title,
        message: message,
        type: ToastType.warning,
        duration: duration,
      );

  static void info(String title, {String? message, Duration? duration}) =>
      show(title, message: message, type: ToastType.info, duration: duration);

  static void dismissAll() => _controller.dismissAll();
}

class _ToastData {
  _ToastData(this.id, this.title, this.message, this.type, this.duration);

  final int id;
  final String title;
  final String? message;
  final ToastType type;
  final Duration duration;

  /// Incremented when the same toast is requested again while visible.
  int bump = 0;
  bool dismissing = false;
}

class _ToastController extends ChangeNotifier {
  final List<_ToastData> items = [];
  int _nextId = 0;

  void add(String title, String? message, ToastType type, Duration duration) {
    type.haptic();

    // Same toast already on screen → nudge it instead of stacking a copy.
    for (final t in items.reversed) {
      if (!t.dismissing &&
          t.title == title &&
          t.message == message &&
          t.type == type) {
        t.bump++;
        notifyListeners();
        return;
      }
    }

    items.add(_ToastData(_nextId++, title, message, type, duration));
    notifyListeners();
  }

  void remove(int id) {
    items.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void dismissAll() {
    for (final t in items) {
      t.dismissing = true;
    }
    notifyListeners();
  }
}

const _maxVisible = 3;

class AppToastHost extends StatelessWidget {
  const AppToastHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = Toast._controller;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Material(
              type: MaterialType.transparency,
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  final items = controller.items;
                  if (items.isEmpty) return const SizedBox.shrink();
                  return SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            for (var i = 0; i < items.length; i++)
                              _ToastCard(
                                key: ValueKey(items[i].id),
                                data: items[i],
                                depth: items.length - 1 - i,
                                onRemoved: () => controller.remove(items[i].id),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({
    super.key,
    required this.data,
    required this.depth,
    required this.onRemoved,
  });

  final _ToastData data;

  /// 0 = newest (front), 1.. = older toasts tucked behind.
  final int depth;
  final VoidCallback onRemoved;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with TickerProviderStateMixin {
  // Close to critically damped: settles quickly with only a hint of overshoot.
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 320,
    damping: 30,
  );

  /// 0 = off-screen above, 1 = resting.
  late final AnimationController _enter = AnimationController.unbounded(
    vsync: this,
  );

  /// Vertical drag offset in logical pixels.
  late final AnimationController _drag = AnimationController.unbounded(
    vsync: this,
  );

  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
    reverseDuration: const Duration(milliseconds: 220),
  );

  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  Timer? _timer;
  late Duration _remaining = widget.data.duration;
  DateTime? _timerStartedAt;
  double _rawDrag = 0;
  bool _exiting = false;
  late int _seenBump = widget.data.bump;

  @override
  void initState() {
    super.initState();
    _enter.animateWith(SpringSimulation(_spring, 0, 1, 0));
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _ToastCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.dismissing || widget.depth >= _maxVisible) {
      _dismiss();
    } else if (widget.data.bump != _seenBump) {
      _seenBump = widget.data.bump;
      _bump.forward(from: 0);
      _remaining = widget.data.duration;
      _startTimer();
    }
  }

  void _startTimer() {
    if (_exiting) return;
    _timer?.cancel();
    _timerStartedAt = DateTime.now();
    _timer = Timer(_remaining, _dismiss);
  }

  void _pauseTimer() {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
      final elapsed = DateTime.now().difference(_timerStartedAt!);
      _remaining = _remaining - elapsed;
      if (_remaining < const Duration(milliseconds: 1200)) {
        _remaining = const Duration(milliseconds: 1200);
      }
    }
  }

  void _dismiss() {
    if (_exiting) return;
    _exiting = true;
    _timer?.cancel();
    _enter
        .animateTo(
          0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInCubic,
        )
        .whenCompleteOrCancel(() {
          if (mounted) widget.onRemoved();
        });
  }

  // Up: follows the finger. Down: resists, so the card can't be pulled far.
  double _rubberBand(double x) => x <= 0 ? x : 28 * (1 - math.exp(-x / 70));

  @override
  void dispose() {
    _timer?.cancel();
    _enter.dispose();
    _drag.dispose();
    _press.dispose();
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.data.type;
    final color = type.color;
    final front = widget.depth == 0;

    final card = Semantics(
      liveRegion: true,
      container: true,
      label: [widget.data.title, ?widget.data.message].join('. '),
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: front ? 1 : 0),
            duration: const Duration(milliseconds: 220),
            builder: (context, v, child) => Opacity(opacity: v, child: child),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(type.icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.title,
                          style: const TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        if (widget.data.message != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.data.message!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final interactive = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        _pauseTimer();
        _press.forward();
      },
      onTapUp: (_) {
        _press.reverse();
        _dismiss();
      },
      onTapCancel: () {
        _press.reverse();
        _startTimer();
      },
      onVerticalDragStart: (_) {
        _pauseTimer();
        _drag.stop();
        _rawDrag = _drag.value;
      },
      onVerticalDragUpdate: (d) {
        _rawDrag += d.delta.dy;
        _drag.value = _rubberBand(_rawDrag);
      },
      onVerticalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (_rawDrag < -24 || v < -350) {
          _dismiss();
        } else {
          _rawDrag = 0;
          _drag.animateWith(SpringSimulation(_spring, _drag.value, 0, v));
          _startTimer();
        }
      },
      child: card,
    );

    final hiddenOffset = -(MediaQuery.paddingOf(context).top + 120);

    return IgnorePointer(
      ignoring: !front || _exiting,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: widget.depth.clamp(0, _maxVisible).toDouble()),
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        builder: (context, depth, child) => Transform.translate(
          offset: Offset(0, depth * 8),
          child: Transform.scale(
            scale: 1 - depth * 0.05,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_enter, _drag, _press, _bump]),
          child: interactive,
          builder: (context, child) {
            final t = _enter.value;
            final press = 1 - 0.02 * Curves.easeOut.transform(_press.value);
            final b = _bump.value;
            final nudge = math.sin(b * math.pi * 3) * (1 - b) * 5;

            return Transform.translate(
              offset: Offset(nudge, (1 - t) * hiddenOffset + _drag.value),
              child: Transform.scale(
                scale: (0.96 + 0.04 * t) * press,
                alignment: Alignment.topCenter,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
