import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

enum _AniProps { opacity, translateX }

class FadeInVertical extends StatelessWidget {
  final double delay;
  final double distance;
  final int duration;
  final Widget child;
  final Curves curves;

  FadeInVertical({this.delay, this.distance, this.duration, this.curves, this.child});

  @override
  Widget build(BuildContext context) {
    // @formatter:off
    final tween = MultiTween<_AniProps>()
      ..add(_AniProps.opacity, 0.0.tweenTo(1.0))
      ..add(_AniProps.translateX, distance.tweenTo(0.0));

    return PlayAnimation<MultiTweenValues<_AniProps>>(
      delay: (300 * delay).round().milliseconds,
      duration: duration.milliseconds,
      curve: Curves.easeOut,
      tween: tween,
      child: child,
      builder: (context, child, value) => Opacity(
        opacity: value.get(_AniProps.opacity),
        child: Transform.translate(
          offset: Offset(
            0,
            value.get(_AniProps.translateX),
          ),
          child: child,
        ),
      ),
    );
  }
}
