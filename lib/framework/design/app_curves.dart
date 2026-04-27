import 'package:flutter/animation.dart';

class AppCurves {
  const AppCurves._();

  // Material 3 motion: emphasized for entrances, standard for other transitions.
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve standard = Cubic(0.4, 0.0, 0.2, 1.0);
}
