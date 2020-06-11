import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sized_context/sized_context.dart';
import 'package:supercharged/supercharged.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../animations/anim_FadeInVT.dart';
import '../../data/provider/news_provider.dart';
import '../../helpers/custom_card.dart';
import '../../helpers/custom_color.dart';
import '../../packages/expandable_news/expandable.dart';
import '../../services/service_locator.dart';

class NewsMainHome extends StatefulWidget {
  NewsMainHome();

  @override
  _NewsMainHomeState createState() => _NewsMainHomeState();
}

class _NewsMainHomeState extends State<NewsMainHome> with TickerProviderStateMixin {
  final log = sl<Logger>();
  var news;
  String address;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    news = Provider.of<NewsDataProvider>(context).newsData;

    return CustomCard(
      borderRadius: [10, 10, 5, 5],
      padding: [0, 0, 0, 0],
      elevation: 6,
      shadowColor: Colors.black,
      color: Color.fromRGBO(35, 47, 52, 0.8),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            CustomCard(
              borderRadius: [10, 10, 0, 0],
              elevation: 3,
              color: Colors.black54,
              child: Container(
                  height: 25,
                  width: context.widthPx,
                  child: Text(
                    "News",
                    textAlign: TextAlign.center,
                  )),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(height: 6),
                      FluidLayout(
                        horizontalPadding: FluidValue((_) => 0),
                        child: Fluid(
                          horizontalPadding: 5,
                          child: (news == null)
                              ? Center(child: CircularProgressIndicator())
                              : FadeInVertical(
                                  delay: 0,
                                  distance: -75,
                                  duration: 500,
                                  child: ExpandableNotifier(
                                      type: "news",
                                      child: Card(
                                        color: Color.fromRGBO(33, 33, 33, 0.9),
                                        clipBehavior: Clip.antiAlias,
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: <Widget>[
                                            AnimatedSize(
                                              curve: Curves.easeIn,
                                              duration: 300.milliseconds,
                                              vsync: this,
                                              child: Container(
                                                constraints: BoxConstraints(
                                                  /*minHeight: 50,*/ maxHeight: 200,
                                                  maxWidth: context.widthPx,
                                                ),
                                                child: (news[0].image == null)
                                                    ? AssetImage('assets/images/searcher_default.png')
                                                    : FadeInImage.memoryNetwork(
                                                        placeholderCacheHeight: 115,
                                                        placeholderCacheWidth: 100,
                                                        placeholder: kTransparentImage,
                                                        image: '${data.getString("address")}/${news[0].image}',
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                              ),
                                            ),
                                            ScrollOnExpand(
                                              scrollOnExpand: true,
                                              scrollOnCollapse: false,
                                              child: ExpandablePanel(
                                                theme: const ExpandableThemeData(
                                                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                                                  tapBodyToCollapse: true,
                                                ),
                                                header: Container(
                                                  child: Padding(
                                                    padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
                                                    child: Text(
                                                      '${news[0].title}',
                                                      softWrap: true,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                                                        fontSize: 13,
                                                        color: Color(0xFF607FAE),
                                                        shadows: [Shadow(color: AppColors.DARK_DARK, blurRadius: 1)],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                collapsed: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                      child: Text(
                                                        '${news[0].description}',
                                                        softWrap: true,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: Theme.of(context).textTheme.subtitle2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                expanded: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    for (var _ in Iterable.generate(5))
                                                      Padding(
                                                          padding: EdgeInsets.only(bottom: 10, left: 0),
                                                          child: Text(
                                                            '${news[0].details}',
                                                            softWrap: true,
                                                            overflow: TextOverflow.fade,
                                                            style: Theme.of(context).textTheme.subtitle2,
                                                          )),
                                                  ],
                                                ),
                                                builder: (_, collapsed, expanded) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Expandable(
                                                      collapsed: collapsed,
                                                      expanded: expanded,
                                                      theme: const ExpandableThemeData(crossFadePoint: 0),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
