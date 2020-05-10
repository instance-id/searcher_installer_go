import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer/animations/slide_in.dart';
import 'package:searcher_installer/data/models/news_data.dart';
import 'package:searcher_installer/data/provider/news_provider.dart';
import 'package:searcher_installer/helpers/custom_card.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:sized_context/sized_context.dart';

class NewsMainHome extends StatefulWidget {
  NewsMainHome();

  @override
  _NewsMainHomeState createState() => _NewsMainHomeState();
}

class _NewsMainHomeState extends State<NewsMainHome> with TickerProviderStateMixin {
  final Logger log = new Logger();
  List<NewsData> news;

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
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
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
            SizedBox(
              height: 2,
            ),
            FluidLayout(
                horizontalPadding: FluidValue((_) => 0),
                child: Fluid(
                    horizontalPadding: 10,
                    child: (news == null)
                        ? Center(child: CircularProgressIndicator())
                        : Container(
                            child: SlideFadeIn(
                                begin: -130.0,
                                end: 0,
                                direction: "translateX",
                                delay: 0,
                                child: Container(
                                  child: Column(children: [
                                    SizedBox(height: 4),
                                    AnimatedSize(
                                      curve: Curves.easeIn,
                                      duration: new Duration(milliseconds: 300),
                                      vsync: this,
                                      child: Container(
                                          constraints: BoxConstraints(minHeight: 115),
                                          child: (news[0].image == null)
                                              ? AssetImage('assets/images/searcher_default.png')
                                              : FadeInImage.memoryNetwork(
                                                  placeholderCacheHeight: 115,
                                                  placeholder: kTransparentImage,
                                                  image: 'https://instance.id/${news[0].image}',
                                                  fit: BoxFit.fitWidth,
                                                )),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('${news[0].title}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color.fromRGBO(222, 222, 222, .9),
                                              )),
                                          Text('${news[0].description}', style: TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ))))),
          ],
        ),
      ),
    );
  }
}
