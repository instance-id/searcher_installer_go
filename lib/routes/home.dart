import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:searcher_installer/routes/widgets/change_log_list.dart';
import 'package:searcher_installer/routes/widgets/news_main_home.dart';
import 'package:fluid_layout/fluid_layout.dart';


const appTitle = "Searcher : Installer";
bool startCompleted = false;

class Home extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final Logger log = new Logger();
  bool loadingComplete = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(flex: 1, child: NewsMainHome()),
                    SizedBox(width: 25),
                    Flexible(flex: 1, child: ChangeLogList()),
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
