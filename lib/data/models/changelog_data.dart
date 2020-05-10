import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

class ChangeLogData {
  final String id;
  final String details;
  final String version;
  final String title;
  final String description;
  final String dateposted;
  final String project;
  final String image;
  final String image_small;

  IconData iconData;

  String address = GlobalConfiguration().getString("address");

  ChangeLogData({this.description, this.details, this.version, this.title, this.id, this.dateposted, this.project, this.image, this.image_small});

  ChangeLogData.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        details = parsedJson['details'],
        version = parsedJson['version'],
        description = parsedJson['description'],
        title = parsedJson['title'],
        dateposted = parsedJson['dateposted'],
        project = parsedJson['project'],
        image = parsedJson['image'],
        image_small = parsedJson['image_small'];
}
