import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double elevation;
  final double roundness;
  final Color shadowColor;
  final List<double> borderRadius;
  final List<double> padding;
  final Function() onTap;

  const CustomCard({
    Key key,
    this.child,
    this.color,
    this.elevation = 12,
    this.roundness = 10,
    this.shadowColor = Colors.black87,
    this.borderRadius = const [10, 10, 10, 10],
    this.padding = const [0, 0, 0, 0],
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius[0]),
          topRight: Radius.circular(borderRadius[1]),
          bottomRight: Radius.circular(borderRadius[2]),
          bottomLeft: Radius.circular(borderRadius[3]),
        ),
      ),
      child: InkWell(
          child: Padding(
            child: child,
            padding: EdgeInsets.fromLTRB(
              padding[0],
              padding[1],
              padding[2],
              padding[3],
            ),
          ),
          onTap: onTap,
          borderRadius: BorderRadius.circular(10)),
      shadowColor: shadowColor,
      elevation: elevation,
    );
  }
}
