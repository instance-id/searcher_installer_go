import 'package:flutter/material.dart';
import 'package:searcher_installer_go/data/models/news_data.dart';
import 'package:searcher_installer_go/helpers/custom_card.dart';

import 'news_details.dart';

class NewsItem extends StatelessWidget {
  final NewsData news;

  NewsItem(this.news);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      elevation: 4,
      shadowColor: Colors.black,
      color: Color.fromRGBO(35, 47, 52, 0.9),
      child: ListTile(
        subtitle: Text(news.description),
        title: Text(
          news.title,
          style: TextStyle(color: Colors.white),
        ),
        onTap: () {
          Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) => NewsDetails(
                    id: news.id,
                    title: news.title,
                    project: news.project,
                  )));
        },
      ),
    );
  }
}
