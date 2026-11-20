import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:teamtasks/router/motion.dart';

/// Lazily-built, state-preserving tab host with an M3 fade-through switch.
class FadeThroughIndexedStack extends StatefulWidget {
  const FadeThroughIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<FadeThroughIndexedStack> createState() =>
      _FadeThroughIndexedStackState();
}

class _FadeThroughIndexedStackState extends State<FadeThroughIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.tabSwitch,
    value: 1.0,
  );
  late int _current = _clamp(widget.index);
  int? _previous;
  int _generation = 0;
  late final Set<int> _visited = {_current};

  late final Animation<double> _fadeIn = _c.drive(
    CurveTween(curve: AppMotion.tabIn),
  );
  late final Animation<double> _fadeOut = ReverseAnimation(
    _c.drive(CurveTween(curve: AppMotion.tabOut)),
  );
  late final Animation<double> _scaleIn = _c.drive(
    Tween<double>(
      begin: AppMotion.tabScaleFrom,
      end: 1.0,
    ).chain(CurveTween(curve: AppMotion.tabIn)),
  );

  /// Out-of-range indexes fall back to the first tab.
  int _clamp(int i) => (i >= 0 && i < widget.children.length) ? i : 0;

  /// The point of [AppMotion.tabOut] where the outgoing opacity equals [op].
  /// tabOut is Interval(0, .35, easeInCubic), so 1 - (c/.35)^3 = op.
  double _fadeOutStartFor(double op) =>
      0.35 * math.pow((1.0 - op).clamp(0.0, 1.0), 1 / 3).toDouble();

  @override
  void didUpdateWidget(FadeThroughIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int next = _clamp(widget.index);
    if (next == _current) return;
    _visited.add(next);

    if (MediaQuery.disableAnimationsOf(context)) {
      _previous = null;
      _current = next;
      _c.value = 1.0;
      return;
    }

    final bool interrupted = _c.isAnimating;
    final double t = _c.value;
    final int? prev = (_previous != null && _previous! < widget.children.length)
        ? _previous
        : null;
    double from = 0.0;

    if (interrupted && t < 0.35 && prev != null) {
      // The tab that was coming in is still invisible (its fade starts at
      // .35); the outgoing tab is mid fade-out.
      if (next == prev) {
        // Tapped back to the outgoing tab: just show it again.
        _current = next;
        _previous = null;
        _generation++;
        _c.value = 1.0;
        return;
      }
      // Skip the invisible tab and keep fading the outgoing one.
      _current = next;
      from = t;
    } else {
      final int? outgoing = _current < widget.children.length ? _current : null;
      if (interrupted && t >= 0.35 && outgoing != null) {
        // The outgoing tab was partly faded in: fade it out from there.
        from = _fadeOutStartFor(AppMotion.tabIn.transform(t));
      }
      _previous = outgoing;
      _current = next;
    }

    final int generation = ++_generation;
    _c.forward(from: from).whenCompleteOrCancel(() {
      if (mounted && generation == _generation) {
        setState(() => _previous = null);
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (int i = 0; i < widget.children.length; i++)
          if (_visited.contains(i))
            KeyedSubtree(
              key: ValueKey<int>(i),
              child: Offstage(
                offstage: i != _current && i != _previous,
                child: TickerMode(
                  enabled: i == _current || i == _previous,
                  child: IgnorePointer(
                    ignoring: i != _current,
                    child: ExcludeFocus(
                      excluding: i != _current,
                      child: FadeTransition(
                        opacity: i == _current
                            ? _fadeIn
                            : (i == _previous
                                  ? _fadeOut
                                  : kAlwaysCompleteAnimation),
                        child: ScaleTransition(
                          scale: i == _current
                              ? _scaleIn
                              : kAlwaysCompleteAnimation,
                          child: widget.children[i],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
