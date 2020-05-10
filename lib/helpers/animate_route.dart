import 'package:flutter/material.dart';

class AnimateRoute<T> extends MaterialPageRoute<T> {
  AnimateRoute(
      {WidgetBuilder builder, bool fullscreenDialog, RouteSettings settings})
      : super(
            builder: builder,
            fullscreenDialog:
                fullscreenDialog == null ? false : fullscreenDialog,
            settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    Animation<Offset> _offsetFloat;
    if (settings.name == "remotes") {
      return child;
    }

    _offsetFloat = Tween(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(animation);

    return SlideTransition(
      position: _offsetFloat,
      textDirection: TextDirection.ltr,
      child: child,
    );
  }
}
