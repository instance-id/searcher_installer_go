import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:dynamic_widget/dynamic_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer_go/animations/anim_FadeInVT.dart';
import 'package:searcher_installer_go/data/models/news_data.dart';
import 'package:searcher_installer_go/data/provider/news_provider.dart';
import 'package:searcher_installer_go/helpers/custom_card.dart';
import 'package:searcher_installer_go/routes/widgets/expansion_news.dart';
import 'package:sized_context/sized_context.dart';

var jsonString = '''
{
  "type": "ListView",
  "padding": "10, 10, 10, 0",
  "pageSize": 1,
  "children":[
    {
      "type": "ListTile",
      "leading": {
        "type":"Text",
        "data":"Leading text"
      },
      "title":{
        "type":"Text",
        "data":"Sup?"
      },
      "subtitle":{
        "type":"Text",
        "data":"More Sup?"
      }
    }
  ]
}

''';

bool startCompleted = false;

class DefaultClickListener implements ClickListener {
  @override
  void onClicked(String event) {
    print("Receive click event: " + event);
  }
}

class News extends StatefulWidget {
  static const routeName = '/information';

  @override
  _NewsState createState() => _NewsState();
}

final sl = GetIt.instance;

class _NewsState extends State<News> with TickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  GlobalConfiguration config = GlobalConfiguration();

  final log = sl<Logger>();
  List<NewsData> news;

  @override
  void initState() {
    super.initState();
  }

  Future<Widget> _buildWidget(BuildContext context, String json) async {
    return DynamicWidgetBuilder.build(json, context, new DefaultClickListener());
  }

  Future<Widget> _dynamicContent(BuildContext context, String json) async {
    return FutureBuilder<Widget>(
      future: _buildWidget(context, json),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }
        return snapshot.hasData
            ? SizedBox(
                height: 100,
                width: 300,
                child: snapshot.data,
              )
            : Text("Loading...");
      },
    );
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
          children: <Widget> [
            CustomCard(
              borderRadius: [10, 10, 0, 0],
              elevation: 3,
              color: Colors.black87,
              child: Container(
                  height: 25,
                  width: context.widthPx,
                  child: Text(
                    "News",
                    textAlign: TextAlign.center,
                  )),
            ),
            Expanded(
              flex: 1,
              child: CustomCard(
                padding: [0, 6, 0, 0],
                borderRadius: [0, 0, 10, 10],
                elevation: 10,
                shadowColor: Colors.black,
                color: Color.fromRGBO(35, 47, 52, 0.8),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Scaffold(
                        body: (news == null)
                            ? Center(child: CircularProgressIndicator())
                            : DraggableScrollbar.arrows(
                                alwaysVisibleScrollThumb: true,
                                backgroundColor: Color.fromRGBO(35, 35, 35, 0.9),
                                padding: EdgeInsets.only(right: 2),
                                controller: _scrollController,
                                child: ListView.separated(
                                  controller: _scrollController,
                                  itemCount: news.length,
                                  separatorBuilder: (context, __) => SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    return (news[index].isDynamic)
                                        ? Center(child: CircularProgressIndicator())
                                        : FadeInVertical(
                                            delay: (index.toDouble() * 0.3) + 0.3,
                                            distance: -75,
                                            duration: 500,
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(10, 0, 23, 0),
                                              child: ExpansionNews(news[index], index),
                                            ),
                                          );
                                  },
                                ),
                                heightScrollThumb: 48.0,
                              ),
                      ),
                    ),
                  ],
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
