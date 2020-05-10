import 'package:flutter/animation.dart';

class AnimateCharts {
  AnimateCharts(this.chartController)
      : chartPosition = new Tween(begin: -150.0, end: 0.0).animate(
          new CurvedAnimation(
            parent: chartController,
            curve: new Interval(
              0.150,
              0.330,
              curve: Curves.ease,
            ),
          ),
        ),
        chartOpacity = new Tween(begin: 0.0, end: 1.0).animate(
          new CurvedAnimation(
            parent: chartController,
            curve: new Interval(
              0.150,
              0.250,
              curve: Curves.easeIn,
            ),
          ),
        ),
        chartHeight = new Tween(begin: 0.0, end: 15.0).animate(
          new CurvedAnimation(
            parent: chartController,
            curve: new Interval(
              0.100,
              0.320,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        );

  double chartValues(double order, double current) {
    var adjustedValue = new Tween(begin: 0.00, end: current).animate(
      new CurvedAnimation(
        parent: chartController,
        curve: new Interval(
          0.11 * (order / 0.99),
          0.14 * (order * 0.99),
          curve: Curves.easeOutBack,
        ),
      ),
    );
    return adjustedValue.value;
  }

  final AnimationController chartController;
  final Animation<double> chartPosition;
  final Animation<double> chartOpacity;
  final Animation<double> chartHeight;
}
