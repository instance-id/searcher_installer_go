import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sized_context/sized_context.dart';
import 'package:supercharged/supercharged.dart';

import '../../animations/anim_FadeInVT.dart';
import '../../data/provider/news_provider.dart';
import '../../helpers/custom_card.dart';
import '../../packages/expandable_news/expandable.dart';
import '../../services/service_locator.dart';
import 'news_home_item.dart';

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

  final themeData = ExpandableThemeData(
    headerAlignment: ExpandablePanelHeaderAlignment.center,
    useInkWell: false,
    tapBodyToCollapse: false,
    crossFadePoint: 0.8,
    tapBodyToExpand: false,
    animationDuration: 300.milliseconds,
    fadeCurve: Curves.easeIn,
    sizeCurve: Curves.easeInOutQuart,
  );

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
            SizedBox(height: 6),
            FluidLayout(
              horizontalPadding: FluidValue((_) => 0),
              child: Fluid(
                horizontalPadding: 3,
                child: (news == null)
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        children: <Widget>[
                          Container(
                            height: context.heightPx - 165,
                            child: ListView.separated(
//                            controller: _scrollController,
                              itemCount: data.get('maxNews')["enabled"]
                                  ? data.get('maxNews')["num"]
                                  : news.length,
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              scrollDirection: Axis.vertical,
                              separatorBuilder: (context, __) => SizedBox(height: 5),
                              itemBuilder: (context, index) => FadeInVertical(
                                delay: (index.toDouble() * 0.3) + 0.3,
                                distance: -75,
                                duration: 500,
                                child: NewsHomeItem(
                                  key: ValueKey('${news[index].id}'),
                                  news: news[index],
                                  themeData: themeData,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
