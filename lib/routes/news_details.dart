import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer/data/models/news_data.dart';
import 'package:searcher_installer/data/provider/news_provider.dart';
import 'package:searcher_installer/helpers/custom_card.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:supercharged/supercharged.dart';
import 'package:sized_context/sized_context.dart';

class NewsDetails extends StatefulWidget {
  final String id;
  final String title;
  final String project;

  NewsDetails({@required this.id, @required this.title, this.project});

  @override
  _NewsDetailsState createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var infoService = Provider.of<NewsDataProvider>(context);

    Widget _topRow(NewsData news, BuildContext context) {
      return Container(
        child: AnimatedSize(
            curve: Curves.easeIn,
            duration: new Duration(milliseconds: 300),
            vsync: this,
            child: Column(
              children: [
                IntrinsicHeight(
                  child: CustomCard(
                    padding: [10, 10, 10, 10],
                    borderRadius: [10, 10, 10, 10],
                    elevation: 10,
                    color: Color.fromRGBO(35, 47, 52, 0.8),
                    child: Row(
                      children: [
                        Container(
                          constraints: BoxConstraints(minHeight: 115, maxWidth: 300),
                          child: (news.image == null)
                              ? AssetImage('assets/images/searcher_default.png')
                              : FadeInImage.memoryNetwork(
                                  placeholderCacheHeight: 115,
                                  placeholder: kTransparentImage,
                                  image: '${news.address}/${news.image}',
                                  fit: BoxFit.fitHeight,
                                ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Center(
                                child: Text('${news.project}',
                                    // ignore: deprecated_member_use
                                    style: Theme.of(context).textTheme.headline.copyWith(
                                          color: Colors.white70,
                                          fontSize: 20.0,
                                        )),
                              ),
                              Center(
                                child: Text('${news.dateposted}',
                                    // ignore: deprecated_member_use
                                    style: Theme.of(context).textTheme.headline.copyWith(
                                          color: Colors.white70,
                                          fontSize: 20.0,
                                        )),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )),
      );
    }

    Widget _bottomRow(NewsData news, BuildContext context) {
      return Container(
        child: CustomCard(
          color: Color.fromRGBO(35, 47, 52, 0.8),
          borderRadius: [10, 10, 10, 10],
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  heightFactor: 0.8,
                  child: Text('${news.title}',
                      // ignore: deprecated_member_use
                      style: Theme.of(context).textTheme.headline.copyWith(
                            color: Colors.white70,
                            fontSize: 20.0,
                          )),
                ),
                Divider(height: 15, color: Colors.white70),
                SizedBox(height: 10),
                Container(
                  child: Center(
                    child: Text(
                      "${news.details}",
                      // ignore: deprecated_member_use
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Colors.white70,
                            height: 1.3,
                            fontSize: 15.0,
                          ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: Colors.transparent,
          child: FutureProvider(
            create: (context) => infoService.fetchnewsitem(widget.id, widget.project),
            child: Center(
              child: Consumer<NewsData>(builder: (context, news, widget) {
                return (news == null)
                    ? CircularProgressIndicator()
                    : GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: FluidLayout(
                              horizontalPadding: FluidValue((_) => 0),
                              child: Fluid(
                                child: Stack(children: <Widget>[
                                  Center(
                                    child: Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.fromLTRB(0, 22, 0, 30),
                                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        height: MediaQuery.of(context).size.height - 122,
                                        child: CustomCard(
                                          elevation: 2,
                                          shadowColor: Colors.black,
                                          color: Color.fromRGBO(55, 55, 55, 0.1),
                                          child: AnimatedSize(
                                              curve: Curves.easeIn,
                                              duration: 300.milliseconds,
                                              vsync: this,
                                              child: Padding(
                                                padding: const EdgeInsets.all(6.0),
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(3.0),
                                                        child: _topRow(news, context),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(3.0),
                                                        child: _bottomRow(news, context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        )),
                                  ),
                                ]),
                              )),
                        ));
              }),
            ),
          ),
        ));
  }
}
