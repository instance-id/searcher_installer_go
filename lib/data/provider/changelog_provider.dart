import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:searcher_installer_go/data/models/changelog_data.dart';

class ChangeLogDataProvider with ChangeNotifier {
  var log = Logger();
  List<ChangeLogData> changeLog;
  bool _fetchComplete = false;

  init() {
    getChanges();
  }

  List<ChangeLogData> getChanges() {
    if (!_fetchComplete) {
      fetchchangelogs().then((value) {
        changeLog = value;
        _fetchComplete = true;
        notifyListeners();
      }).catchError((e) => log.e("Cannot get news data: $e"));
    }
  }

  Future<List<ChangeLogData>> fetchchangelogs() async {
    var response = await http.get("https://instance.id/api/v1.0/changelog/changelog.json");
    var jsonResponse = convert.jsonDecode(response.body) as List;

    return jsonResponse.map((changeLog) => ChangeLogData.fromJson(changeLog)).toList();
  }

  Future<ChangeLogData> fetchchangelog(String id, String project) async {
    var response = await http.get("https://instance.id/api/v1.0/changelog/$project/$id/json.json");
    var jsonResponse = convert.jsonDecode(response.body);

    return ChangeLogData.fromJson(jsonResponse);
  }
}
