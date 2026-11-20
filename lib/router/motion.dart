import 'package:material_ui/material_ui.dart';

abstract final class AppMotion {
  static const Color surface = Color(0xFFF5F5F5); // Colors.grey.shade100
  static const Color homeSurface = Color(0xFFEEEEEE); // Colors.grey.shade200

  static const Duration rootEnter = Duration(milliseconds: 360);
  static const Duration rootEnterReduced = Duration(milliseconds: 150);
  static const Curve rootFade = Interval(0.0, 0.65, curve: Curves.easeOut);
  static const Curve rootScale = Curves.easeOutCubic;
  static const double enterScaleFrom = 0.96;
  static const double exitScaleFrom = 1.04;

  static const Duration curtainCover = Duration(milliseconds: 160);
  static const Curve curtainCoverCurve = Curves.easeOutCubic;
  static const Duration curtainReveal = Duration(milliseconds: 300);
  static const Curve curtainRevealCurve = Curves.easeOutCubic;
  static const Duration curtainSpinnerDelay = Duration(milliseconds: 400);
  static const Duration settleTimeout = Duration(milliseconds: 800);

  static const Duration tabSwitch = Duration(milliseconds: 240);
  static const Curve tabOut = Interval(0.0, 0.35, curve: Curves.easeInCubic);
  static const Curve tabIn = Interval(0.35, 1.0, curve: Curves.easeOutCubic);
  static const double tabScaleFrom = 0.98;
}
