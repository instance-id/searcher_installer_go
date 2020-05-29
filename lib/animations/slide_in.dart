import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:sa_v1_migration/sa_v1_migration.dart';


AnimationStatusListener animStatus;
bool _setupComplete = false;

bool get setupComplete => _setupComplete;

set setupComplete(bool completed) => _setupComplete = completed;

void _listenToAnimationFinished(status) {
  if (status == AnimationStatus.completed) {
    setupComplete = false;
  }
}

enum AniProps { opacity, translateX, width, height, color, offset }

class SlideFadeIn extends StatelessWidget {
  SlideFadeIn({Key key, this.direction, this.begin, this.end, this.delay, this.child}) : super(key: key);

  final String direction;
  final double begin;
  final double end;
  final double delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("opacity").add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track(direction).add(Duration(milliseconds: 500), Tween(begin: begin, end: end), curve: Curves.easeOut),
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      playback: _setupComplete ? Playback.PAUSE : Playback.PLAY_FORWARD,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(offset: Offset(animation[direction], 0), child: child),
      ),
      animationControllerStatusListener: _listenToAnimationFinished,
    );
  }
}
