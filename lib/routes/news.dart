import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:expansion_card/expansion_card.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer/data/models/news_data.dart';
import 'package:searcher_installer/data/provider/news_provider.dart';
import 'package:searcher_installer/helpers/custom_card.dart';
import 'package:supercharged/supercharged.dart';


import 'news_details.dart';

bool startCompleted = false;

class News extends StatefulWidget {
  static const routeName = '/information';

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> with TickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  final _itemExtent = 100.0;
  final Logger log = new Logger();
  List<NewsData> news;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    news = Provider.of<NewsDataProvider>(context).newsData;

    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 22, 0, 30),
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: CustomCard(
                padding: [10, 12, 10, 0],
                elevation: 10,
                shadowColor: Colors.black,
                color: Color.fromRGBO(35, 47, 52, 0.8),
                child: Scaffold(
                  body: (news == null)
                      ? Center(child: CircularProgressIndicator())
                      : DraggableScrollbar(
                          alwaysVisibleScrollThumb: true,
                          backgroundColor: Colors.deepOrange,
                          padding: EdgeInsets.only(right: 0.0),
                          labelTextBuilder: (double offset) => Text("${offset ~/ _itemExtent}",
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          controller: _scrollController,
                          child: ListView.separated(
                              controller: _scrollController,
                              itemCount: news.length,
                              separatorBuilder: (context, __) => SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                return ExpansionCard(
                                  borderRadius: 5,
                                  margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  title: CustomCard(
                                    padding: [5, 0, 0, 0],
                                    elevation: 6,
                                    borderRadius: [5, 5, 5, 5],
                                    color: Color.fromRGBO(35, 47, 52, 0.8),
                                    child: Container(
                                      height: 55,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "${news[index].title}",
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            textScaleFactor: 0.8,
                                            style: Theme.of(context).textTheme.headline6,
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "v${news[index].dateposted}",
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                textScaleFactor: 0.8,
                                                style: Theme.of(context).textTheme.bodyText1,
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                "${news[index].description}",
                                                overflow: TextOverflow.clip,
                                                softWrap: true,
                                                textScaleFactor: 0.8,
                                                style: Theme.of(context).textTheme.bodyText1,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  children: <Widget>[
                                    Container(
                                      child: Divider(
                                        color: Colors.white30,
                                        height: 2,
                                      ),
                                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                      child: Text(
                                        "${news[index].details}",
                                      ),
                                    )
                                  ],
                                );
                              }),
                          heightScrollThumb: 48.0,
                          scrollThumbBuilder: (
                            Color backgroundColor,
                            Animation<double> thumbAnimation,
                            Animation<double> labelAnimation,
                            double height, {
                            Text labelText,
                            BoxConstraints labelConstraints,
                          }) {
                            return FadeTransition(
                              opacity: thumbAnimation,
                              child: Container(
                                height: height,
                                width: 20.0,
                                color: backgroundColor,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}
