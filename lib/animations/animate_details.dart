import 'package:flutter/animation.dart';

class DetailsAnimation {
  DetailsAnimation(this.controller)
      : backdropOpacity = new Tween(begin: 0.0, end: 1.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.000,
              1.000,
              curve: Curves.ease,
            ),
          ),
        ),
        backdropBlur = new Tween(begin: 0.0, end: 5.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.000,
              0.800,
              curve: Curves.ease,
            ),
          ),
        ),
        avatarSize = new Tween(begin: 0.0, end: 1.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.100,
              0.400,
              curve: Curves.elasticOut,
            ),
          ),
        ),
        dividerWidth = new Tween(begin: 0.0, end: 255.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.250,
              0.600,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        nameOpacity = new Tween(begin: 0.0, end: 1.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.350,
              0.700,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        completionSize = new Tween(begin: 1.0, end: 0.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.450,
              0.800,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        completionValue = new Tween(begin: 0.0, end: 1.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.450,
              0.800,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        descriptionOpacity = new Tween(begin: 0.0, end: 1.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.550,
              0.900,
              curve: Curves.easeIn,
            ),
          ),
        ),
        buttonXTranslation = new Tween(begin: 100.0, end: 0.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.650,
              1.00,
              curve: Curves.ease,
            ),
          ),
        ),
        configureButtonOpacity = new Tween(begin: 0.0, end: 1.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.650,
              1.00,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        );

  final AnimationController controller;
  final Animation<double> backdropOpacity;
  final Animation<double> backdropBlur;
  final Animation<double> avatarSize;
  final Animation<double> nameOpacity;
  final Animation<double> completionSize;
  final Animation<double> completionValue;
  final Animation<double> dividerWidth;
  final Animation<double> descriptionOpacity;
  final Animation<double> buttonXTranslation;
  final Animation<double> configureButtonOpacity;
}
