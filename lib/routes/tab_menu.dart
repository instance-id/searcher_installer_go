import 'package:flutter/material.dart';
import 'package:searcher_installer_go/helpers/navigation-bus.dart';
import 'package:vector_math/vector_math.dart' as vector;

import '../helpers/tab_item.dart';

class TabMenu extends StatefulWidget {
  final ValueChanged<int> onChanged;

  TabMenu({Key key, @required this.onChanged}) : super(key: key);

  @override
  TabMenuState createState() => TabMenuState();
}

class TabMenuState extends State<TabMenu> with TickerProviderStateMixin {
  bool menuHidden = false;
  AnimationController _menuController;
  Tween<Offset> _menuTween;
  Animation<Offset> _menuAnimation;

  AnimationController _animationController;
  Tween<double> _positionTween;
  Animation<double> _positionAnimation;

  AnimationController _fadeOutController;
  Animation<double> _fadeFabOutAnimation;
  Animation<double> _fadeFabInAnimation;
  Animation<double> _fadeFabDownAnimation;

  TabController _bgController;
  Animation _bgAnimation;

  double fabIconAlpha = 1;
  IconData nextIcon = Icons.search;
  IconData activeIcon = Icons.search;

  int currentSelected = 1;

  void move(int idx, {bool hideMenu = false}) {
    menuHidden = hideMenu;
    switch (idx) {
      case 0:
        navInfo();
        break;
      case 1:
        navHome();
        break;
      case 2:
        navUpdate();
        break;
      case 3:
        navDashboard();
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bgController.dispose();
    _menuController.dispose();
    _animationController.dispose();
    _fadeOutController.dispose();
  }

  @override
  void initState() {
    super.initState();

    _bgController = new TabController(vsync: this, length: 3);
    _bgAnimation = _bgController.animation;
    NavigationBus.registerTabController(_bgController);

    _menuController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: (500),
        ));
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: ANIM_DURATION,
        ));
    _fadeOutController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: (ANIM_DURATION ~/ 5),
        ));

    _menuTween = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0));
    _menuAnimation = _menuTween.animate(
      CurvedAnimation(
        parent: _menuController,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    _positionTween = Tween<double>(begin: 0, end: 0);
    _positionAnimation = _positionTween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    _fadeFabOutAnimation = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
      parent: _fadeOutController,
      curve: Curves.easeOut,
    ))
      ..addListener(() {
        setState(() {
          fabIconAlpha = _fadeFabOutAnimation.value;
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            activeIcon = nextIcon;
          });
        }
      });

    _fadeFabInAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.8,
          1,
          curve: Curves.easeOut,
        )))
      ..addListener(() {
        setState(() {
          fabIconAlpha = _fadeFabInAnimation.value;
        });
      });
    setState(() {
      _bgController.animateTo(1);
    });
  }

  void navInfo() {
    setState(() {
      nextIcon = Icons.update;
      currentSelected = 0;
      _bgController.animateTo(0);
    });

    _initAnimationAndStart(_positionAnimation.value, -1);
  }

  void navHome() {
    setState(() {
      nextIcon = Icons.home;
      currentSelected = 1;
      _bgController.animateTo(1);
    });

    _initAnimationAndStart(_positionAnimation.value, 0);
  }

  void navUpdate() {
    setState(() {
      nextIcon = Icons.info;
      fabIconAlpha = .1;
      currentSelected = 2;
      _bgController.animateTo(2);
    });

    _initAnimationAndStart(_positionAnimation.value, 1);
  }

  void navDashboard() {
    setState(() {
      nextIcon = Icons.home;
      fabIconAlpha = .1;
      currentSelected = 1;
      menuHidden = true;
      _bgController.animateTo(3);
    });
    _initAnimationAndStart(_positionAnimation.value, 0, menuHidden: menuHidden);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _menuAnimation,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Color.fromRGBO(35, 35, 35, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 3,
                  offset: Offset(0, -1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TabItem(
                    selected: currentSelected == 0,
//                  iconData: Icons.info,
                    title: "INFO",
                    callbackFunction: () {
                      navInfo();
                      widget.onChanged(0);
                    }),
                TabItem(
                    selected: currentSelected == 1,
//                  iconData: Icons.home,
                    title: "HOME",
                    callbackFunction: () {
                      navHome();
                      widget.onChanged(1);
                    }),
                TabItem(
                    selected: currentSelected == 2,
//                  iconData: Icons.update,
                    title: "UPDATE",
                    callbackFunction: () {
                      navUpdate();
                      widget.onChanged(2);
                    })
              ],
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: Container(
              height: 60,
              decoration: BoxDecoration(color: Colors.transparent),
              child: Align(
                alignment: Alignment(_positionAnimation.value, 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / 3,
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                          width: 50,
                          child: ClipRect(
                              clipper: HalfClipper(),
                              child: Container(
                                alignment: Alignment.topCenter,
                                child: Center(
                                  child: Container(
                                      height: 33,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color:
                                              // --------------------------------- Above Circle ---
                                              Color.fromRGBO(55, 55, 55, 1),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                                // ------------------------------- Above circle shadow
                                                color: Color.fromRGBO(1, 1, 1, .5),
                                                offset: Offset(0, -1),
                                                spreadRadius: 1,
                                                blurRadius: 3)
                                          ])),
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 40,
                          width: 34,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // ------------------------------------------------- Main Circle
                              color: Color(0xFF484848),
                              border: Border.all(
                                  // --------------------------------------------- Inner circle ring
                                  color: Color.fromRGBO(30, 30, 30, 1),
                                  width: 2,
                                  style: BorderStyle.solid),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Opacity(
                                opacity: fabIconAlpha,
                                child: Icon(
                                  activeIcon,
                                  // --------------------------------------------- Middle Icon
                                  color: Color.fromRGBO(230, 111, 13, .9), //color: Color(0xcc82b9ff),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _initAnimationAndStart(double from, double to, {bool menuHidden = false}) {
    if (!menuHidden) {
      _positionTween.begin = from;
      _positionTween.end = to;

      _animationController.reset();
      _fadeOutController.reset();
      _menuController.reverse().orCancel;
      _animationController.forward().orCancel;
      _fadeOutController.forward().orCancel;
    } else {
      _menuController.forward().orCancel;
    }
  }
}

class HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height / 2);
    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class HalfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect beforeRect = Rect.fromLTWH(0, (size.height / 2) - 10, 10, 10);
    final Rect largeRect = Rect.fromLTWH(10, 0, size.width - 20, 70);
    final Rect afterRect = Rect.fromLTWH(size.width - 10, (size.height / 2) - 10, 10, 10);

    final path = Path();
    path.arcTo(beforeRect, vector.radians(0), vector.radians(90), false);
    path.lineTo(20, size.height / 2);
    path.arcTo(largeRect, vector.radians(0), -vector.radians(180), false);
    path.moveTo(size.width - 10, size.height / 2);
    path.lineTo(size.width - 10, (size.height / 2) - 10);
    path.arcTo(afterRect, vector.radians(180), vector.radians(-90), false);
    path.close();
    canvas.drawPath(
      path, // ----------------------------------------------------------------- Background Upper Ring
      Paint()..color = Color.fromRGBO(15, 15, 15, 0),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
