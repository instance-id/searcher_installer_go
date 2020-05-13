import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:searcher_installer_go/helpers/custom_color.dart';
import 'package:sized_context/sized_context.dart';

class RoundButton extends StatefulWidget {
  RoundButton({
    Key key,
    @required this.icon,
    @required this.onPressed,
    @required this.label,
    @required this.loadingController,
    this.interval = const Interval(0, 1, curve: Curves.ease),
    this.size = 60,
  }) : super(key: key);

  final Widget icon;
  final VoidCallback onPressed;
  final String label;
  final AnimationController loadingController;
  final Interval interval;
  final double size;

  @override
  _RoundButtonState createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> with SingleTickerProviderStateMixin {
  AnimationController _pressController;
  Animation<double> _scaleLoadingAnimation;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _scaleLoadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: widget.loadingController,
        curve: widget.interval,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: .75).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOut,
        reverseCurve: ElasticInCurve(0.3),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pressController.dispose();
  }

  void SendPress() {
    _pressController.forward()
        .orCancel.then((_) {
      _pressController.reverse()
          .orCancel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Colors.orange;
//        Colors.primaries.where((c) => c == theme.primaryColor).first;

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: ScaleTransition(
        scale: _scaleLoadingAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                width: context.widthPx,
                height: widget.size * 0.8,
                child: RawMaterialButton(
                  shape: new CircleBorder(),
                  fillColor: primaryColor.shade800,
                  elevation: 0.0,
                  child: widget.icon,
                  onPressed: () {
                    _pressController.forward()
                        .orCancel.then((_) {
                      _pressController.reverse()
                          .orCancel;
                    });
                    widget.onPressed();
                  },
                ),
              ),
            ),
            if (widget.label != "")
              Text(
                widget.label,
                style: theme.textTheme.caption.copyWith(color: AppColors.LIGHT_TEXT),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
