import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../data/models/settings_data.dart';
import '../../data/provider/theme_data.dart';
import '../../services/service_locator.dart';

class SettingsDataProvider with ChangeNotifier {
  var log = sl<Logger>();

  List<SettingsData> settings;
  bool _fetchComplete = false;
  ThemeData theme = themeData;
  bool _messagePending = false;

  bool get messagePending => _messagePending;

  set messagePending(bool value) {
    _messagePending = value;
    notifyListeners();
  }

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
    return jsonResponse.map((settings) => SettingsData.fromJson(settings)).toList();
  }

  Future<SettingsData> fetchsettings() async {
    var response = await http.get("https://instance.id/api/v1.0/settings/settings.json");
    var jsonResponse = convert.jsonDecode(response.body);

    return SettingsData.fromJson(jsonResponse);
  }
}
