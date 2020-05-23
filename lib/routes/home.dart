import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer_go/animations/anim_flex.dart';
import 'package:searcher_installer_go/data/provider/changelog_provider.dart';
import 'package:searcher_installer_go/routes/widgets/change_log_list.dart';
import 'package:searcher_installer_go/routes/widgets/news_main_home.dart';

const appTitle = "Searcher : Installer";
bool startCompleted = false;

class Home extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final Logger log = new Logger();
  AnimationController _controller;
  FlexAnimation flexAnimation;

  bool loadingComplete = false;
  int newsWidth = 10;
  int changeLogWidth = 10;
  bool needsChange = false;

  @override
  void initState() {
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
    flexAnimation = FlexAnimation(_controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });

    super.initState();
  }

  AnimateSize(ChangeLogDataProvider changeLogData) {
    if (!_controller.isAnimating) (changeLogData.getWidth) ? _controller.forward().orCancel : _controller.reverse().orCancel;
    changeLogData.setNeedsExpand(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changeLogData = Provider.of<ChangeLogDataProvider>(context);

    (changeLogData.getWidth) ? changeLogWidth = 30 : changeLogWidth = 10;

    return Material(
      type: MaterialType.transparency,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: Colors.transparent,
          child: FluidLayout(
            horizontalPadding: FluidValue((_) => 0),
            child: Fluid(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 22, 0, 30),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                height: MediaQuery.of(context).size.height - 122,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(flex: newsWidth, child: NewsMainHome()),
                    Spacer(flex: 1),
                    // @formatter:off
                    Expanded(
                      flex: changeLogWidth,
                      child: ChangeLogList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
