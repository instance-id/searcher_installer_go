import 'package:flutter/animation.dart';

class FlexAnimation {
  FlexAnimation(this.controller)
      : flexVal = new Tween(begin: 1.0, end: 3.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.000,
              1.000,
              curve: Curves.ease,
            ),
          ),
        );

  final AnimationController controller;
  final Animation<double> flexVal;
}
