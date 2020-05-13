import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:searcher_installer_go/data/models/settings_data.dart';

class SettingsDataProvider with ChangeNotifier {
  var log = Logger();
  List<SettingsData> settings;
  bool _fetchComplete = false;

  init() {
    getChanges();
  }

  List<SettingsData> getChanges() {
    if (!_fetchComplete) {
      fetchsettingslist().then((value) {
        settings = value;
        _fetchComplete = true;
        notifyListeners();
      }).catchError((e) {
        log.e("Cannot get settings data, using defaults: $e");
      });
    }
    return settings;
  }

  Future<List<SettingsData>> fetchsettingslist() async {
    var response = await http.get("https://instance.id/api/v1.0/settings/settings.json");
    var jsonResponse = convert.jsonDecode(response.body) as List;
    log.i(jsonResponse);
    return jsonResponse.map((settings) => SettingsData.fromJson(settings)).toList();
  }

  Future<SettingsData> fetchsettings() async {
    var response = await http.get("https://instance.id/api/v1.0/settings/settings.json");
    var jsonResponse = convert.jsonDecode(response.body);

    return SettingsData.fromJson(jsonResponse);
  }
}
