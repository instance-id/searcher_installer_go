import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../data/models/news_data.dart';
import '../errors/errors.dart';

class NewsDataProvider with ChangeNotifier {
  var log = Logger();
  List<NewsData> newsData;
  bool _fetchComplete = false;

  init() {
    getNews();
  }

 void getNews() async {
    if (!_fetchComplete) {
      fetchNewsList().then((value) {
        newsData = value;
        _fetchComplete = true;
        notifyListeners();
      }).catchError((e) => log.e("Cannot get news data: $e"));
    }
  }

  Future<List<NewsData>> fetchNewsList() async {
    var jsonResponse;
    try {
      var response = await http.get("https://instance.id/api/v1.0/news/news.json");
      jsonResponse = convert.jsonDecode(response.body) as List;
    } on Exception catch (e) {
      FBError.exceptionToUiMessage(
        FBError(e.toString(), FBFailures.dependency),
      );
      return null;    }
    return await jsonResponse.map<NewsData>((news) => NewsData.fromJson(news)).toList() ;
  }

  Future<NewsData> fetchNewsItem(String id, String project) async {
    var jsonResponse;
    try {
      var response = await http.get("https://instance.id/api/v1.0/news/$project/$id/json.json");
      jsonResponse = convert.jsonDecode(response.body);
    } on Exception catch (e) {
      FBError.exceptionToUiMessage(
        FBError(e.toString(), FBFailures.dependency),
      );
      return null;    }

    return await NewsData.fromJson(jsonResponse);
  }
}
