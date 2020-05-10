import 'package:flutter/material.dart';
import 'package:searcher_installer/helpers/custom_card.dart';

import 'news_details.dart';

class NewsItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      elevation: 4,
      shadowColor: Colors.black,
      color: Color.fromRGBO(35, 47, 52, 0.9),
      child: ListTile(
        focusColor: Colors.redAccent,
        hoverColor: Colors.red.withOpacity(0.5),
        subtitle: Text(news[index].description),
        title: Text(
          news[index].title,
          style: TextStyle(color: Colors.white),
        ),
        onTap: () {
          Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) => NewsDetails(
                id: news[index].id,
                title: news[index].title,
                project: news[index].project,
              )));
        },
      ),
    );
  }
}
