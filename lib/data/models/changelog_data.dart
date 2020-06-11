import 'package:flutter/material.dart';
import 'package:searcher_installer_go/services/service_locator.dart';

class ChangeLogData {
  final String id;
  final String details;
  final String version;
  final String title;
  final String description;
  final String dateposted;
  final String icon;
  final String project;
  final String image;
  final String image_small;
  List<dynamic> itemList;
  String _dynamicString = "false";
  String _markdownString = "false";
  IconData iconData;

  bool get isDynamic => getBool(_dynamicString);
  bool get useMarkdown => getMarkdown(_markdownString);

  bool getBool(String value) {
    return (_dynamicString != null) ? _dynamicString.toLowerCase() == 'true' : false;
  }

  bool getMarkdown(String value) {
    return (_markdownString != null) ? _markdownString.toLowerCase() == 'true' : false;
  }

  String address = data.getString("address");

  ChangeLogData({this.description, this.details, this.version, this.title, this.id, this.dateposted, this.project, this.image, this.image_small, this.icon});

  ChangeLogData.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        details = parsedJson['details'],
        version = parsedJson['version'],
        description = parsedJson['description'],
        title = parsedJson['title'],
        itemList = parsedJson['item_list'],
        dateposted = parsedJson['date'],
        project = parsedJson['project'],
        image = parsedJson['image'],
        image_small = parsedJson['image_small'],
        _dynamicString = parsedJson['is_dynamic'],
        _markdownString = parsedJson['use_markdown'],
        icon = parsedJson['icon'];
}
