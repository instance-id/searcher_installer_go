import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sized_context/sized_context.dart';
import 'package:supercharged/supercharged.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../helpers/custom_color.dart';
import '../../packages/expandable_news/expandable.dart';
import '../../services/service_locator.dart';

class NewsHomeItem extends HookWidget {
  const NewsHomeItem({
    Key key,
    @required this.news,
    @required this.themeData,
  }) : super(key: key);

  final news;
  final ExpandableThemeData themeData;

  @override
  Widget build(BuildContext context) {

    return ExpandableNotifier(
        type: "news",
        child: Card(
          color: Color.fromRGBO(33, 33, 33, 0.9),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              AnimatedSize(
                vsync: useSingleTickerProvider(),
                curve: Curves.easeIn,
                duration: 300.milliseconds,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                    maxWidth: context.widthPx,
                  ),
                  child: (news.image == null)
                      ? AssetImage('assets/images/searcher_default.png')
                      : FadeInImage.memoryNetwork(
                          placeholderCacheHeight: 115,
                          placeholderCacheWidth: 100,
                          placeholder: kTransparentImage,
                          image: '${data.getString("address")}/${news.image}',
                          fit: BoxFit.fitWidth,
                        ),
                ),
              ),
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: true,
                child: ExpandablePanel(
                  theme: themeData,
                  header: Container(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
                      child: Text(
                        '${news.title}',
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
                          '${news.description}',
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
                            padding: EdgeInsets.only(top: 0, bottom: 0, left: 0),
                            child: Text(
                              '${news.details}',
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
                        theme: themeData,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
