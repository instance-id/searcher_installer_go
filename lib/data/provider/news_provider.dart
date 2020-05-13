import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:searcher_installer_go/data/models/news_data.dart';

class NewsDataProvider with ChangeNotifier {
  var log = Logger();
  List<NewsData> newsData;
  bool _fetchComplete = false;

  init() {
    getNews();
  }

  List<NewsData> getNews() {
    if (!_fetchComplete) {
      fetchnewslist().then((value) {
        newsData = value;
        _fetchComplete = true;
        notifyListeners();
      }).catchError((e) => log.e("Cannot get news data: $e"));
    }
  }

  Future<List<NewsData>> fetchnewslist() async {
    var response = await http.get("https://instance.id/api/v1.0/news/news.json");
    var jsonResponse = convert.jsonDecode(response.body) as List;
    return jsonResponse.map((news) => NewsData.fromJson(news)).toList();
  }

  Future<NewsData> fetchnewsitem(String id, String project) async {
    var response = await http.get("https://instance.id/api/v1.0/news/$project/$id/json.json");
    var jsonResponse = convert.jsonDecode(response.body);

    return NewsData.fromJson(jsonResponse);
  }
}
