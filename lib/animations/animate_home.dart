import 'package:flutter/material.dart';
import 'package:searcher_installer/animations/anim_properties.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class HomeAnimation {
  Widget build(BuildContext context) {
    final leftBox = MultiTween<AnimProps>()..add(AnimProps.opacity, 0.0.tweenTo(1.0), 500.milliseconds)..add(AnimProps.translateX, 130.0.tweenTo(0.0), 500.milliseconds, Curves.easeOut);

    return PlayAnimation<MultiTweenValues<AnimProps>>(
        tween: leftBox, // Pass in tween
        duration: leftBox.duration, // Obtain duration from MultiTween
        builder: (context, child, value) {
          return Transform.translate(
              offset: Offset(value.get(AnimProps.translateX), 0),
              child: Container(
                child: child,
              ));
        });
  }
}
