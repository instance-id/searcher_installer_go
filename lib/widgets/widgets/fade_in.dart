import 'package:flutter/material.dart';

enum FadeDirection {
  startToEnd,
  endToStart,
  topToBottom,
  bottomToTop,
}

class FadeIn extends StatefulWidget {
  FadeIn({
    Key key,
    this.fadeDirection = FadeDirection.startToEnd,
    this.offset = 1.0,
    this.controller,
    this.duration,
    this.delay,
    this.curve = Curves.easeOut,
    @required this.child,
  })  : assert(controller == null && duration != null || controller != null && duration == null),
        assert(offset > 0),
        super(key: key);

  /// [FadeIn] animation can be controlled via external [controller]. If
  /// [controller] is not provided, it will use the default internal controller
  /// which will run the animation in initState()
  final AnimationController controller;
  final FadeDirection fadeDirection;
  final double offset;
  final Widget child;
  final Duration duration;
  final double delay;
  final Curve curve;

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;
  bool _isDisposed = false;
  bool _waitForDelay = true;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
    }

    initialize();
  }

  void initialize() async {
    if (widget.delay != null) {
      await Future.delayed(Duration(milliseconds: (300 * widget.delay).round()));
    }
    _waitForDelay = false;
    _updateAnimations();
  }

  void _updateAnimations() {
    if (_isDisposed || _waitForDelay) {
      return;
    }
    Offset begin;
    Offset end;
    final offset = widget.offset;

    switch (widget.fadeDirection) {
      case FadeDirection.startToEnd:
        begin = Offset(-offset, 0);
        end = Offset(0, 0);
        break;
      case FadeDirection.endToStart:
        begin = Offset(offset, 0);
        end = Offset(0, 0);
        break;
      case FadeDirection.topToBottom:
        begin = Offset(0, -offset);
        end = Offset(0, 0);
        break;
      case FadeDirection.bottomToTop:
        begin = Offset(0, offset);
        end = Offset(0, 0);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: _effectiveController,
      curve: widget.curve,
    ));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _effectiveController,
      curve: widget.curve,
    ));

    _controller?.forward()?.orCancel;
  }

  AnimationController get _effectiveController => widget.controller ?? _controller;

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: (_opacityAnimation) ?? 0.1,
        child: widget.child,
      ),
    );
  }
}
