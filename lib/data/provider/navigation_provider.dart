import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  double begin = 0;
  double end = 0;
  bool _animate = true;
  Tween<double> _positionTween = Tween<double>();

  get positionTween => _positionTween;
  set positionTween(Tween<double> value) {
    _positionTween = value;
  }

  get animate => _animate;
  set animate(bool value) {
    _animate = value;
    notifyListeners();
  }

  setAnim(double end) {
    positionTween.begin = begin;
    positionTween.end = end;
     begin = end;
    animate = true;
     notifyListeners();
  }

  NavigationProvider() {
    _positionTween = Tween<double>(begin: begin, end: end);
    setAnim(end);
  }
}
