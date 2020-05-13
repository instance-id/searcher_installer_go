import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer_go/data/models/changelog_data.dart';
import 'package:searcher_installer_go/data/provider/changelog_provider.dart';
import 'package:searcher_installer_go/helpers/custom_card.dart';
import 'package:supercharged/supercharged.dart';
import 'package:transparent_image/transparent_image.dart';

class ChangeLogDetails extends StatefulWidget {
  final String id;
  final String project;
  final IconData iconData;
  final double itemHeight;
  String details;
  String version;
  String title;
  String description;
  String dateposted;
  String image;
  String image_small;

  ChangeLogDetails(this.id, this.project, this.iconData, this.itemHeight);

  @override
  _ChangeLogDetailsState createState() => _ChangeLogDetailsState();
}

class _ChangeLogDetailsState extends State<ChangeLogDetails> with TickerProviderStateMixin {
  var log = Logger();

  @override
  void dispose() {
    GlobalConfiguration().updateValue("title", "Searcher : Home");
    super.dispose();
  }

  @override
  void initState() {
    GlobalConfiguration().updateValue("title", "Searcher : Change Log");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var infoService = Provider.of<ChangeLogDataProvider>(context);

    Widget _topRow(ChangeLogData cLog) {
      return Row(
        children: [
          Flexible(
            flex: 2,
            child: AnimatedSize(
                curve: Curves.easeIn,
                duration: 300.milliseconds,
                vsync: this,
                child: Container(
                    constraints: BoxConstraints(minHeight: 115, maxWidth: 250),
                    child: CustomCard(
                      color: Colors.white30,
                      borderRadius: [10, 3, 3, 20],
                      elevation: 2,
                      child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: (cLog.image == null)
                              ? AssetImage('assets/images/searcher_default.png')
                              : FadeInImage.memoryNetwork(
                                  placeholderCacheHeight: 115,
                                  placeholder: kTransparentImage,
                                  image: '${cLog.address}/${cLog.image}',
                                  fit: BoxFit.fitHeight,
                                )),
                    ))),
          ),
          SizedBox(width: 5),
          Expanded(
            flex: 3,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: new Duration(milliseconds: 300),
              vsync: this,
              child: Center(
                child: Container(
                    alignment: Alignment.center,
                    child: Center(
                      child: Text('${cLog.title}',
                          // ignore: deprecated_member_use
                          style: Theme.of(context).textTheme.headline.copyWith(
                                color: Colors.white70,
                                fontSize: 25.0,
                              )),
                    )),
              ),
            ),
          )
        ],
      );
    }

    Widget _bottomRow(ChangeLogData cLog) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          const SizedBox(height: 10),
          Text(
            "${cLog.details}",
            // ignore: deprecated_member_use
            style: Theme.of(context).textTheme.body1.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                  fontSize: 16.0,
                ),
          )
        ]),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: Scaffold(
        backgroundColor: Colors.transparent,
//        appBar: AppBar(title: const Text('Details page')),
        body: FutureProvider(
          create: (context) => infoService.fetchchangelog(widget.id, widget.project),
          child: Center(child: Consumer<ChangeLogData>(builder: (context, cLog, widget) {
            return (cLog == null)
                ? CircularProgressIndicator()
                : GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      margin: EdgeInsets.fromLTRB(0, 22, 0, 30),
                      child: FluidLayout(
                          horizontalPadding: FluidValue((_) => 0),
                          child: Fluid(
                            child: Stack(children: <Widget>[
                              Center(
                                child: Container(
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height - 122,
                                    child: CustomCard(
                                      elevation: 2,
                                      shadowColor: Colors.black,
                                      color: Color.fromRGBO(35, 47, 52, 0.9),
                                      child: AnimatedSize(
                                          curve: Curves.easeIn,
                                          duration: new Duration(milliseconds: 300),
                                          vsync: this,
                                          child: ListView(
                                            children: <Widget>[
                                              _topRow(cLog),
                                              _bottomRow(cLog),
                                            ],
                                          )),
                                    )),
                              ),
                            ]),
                          )),
                    ));
          })),
        ),
      ),
    );
  }
}
