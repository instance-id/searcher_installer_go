import 'package:global_configuration/global_configuration.dart';

class NewsData {
  final String id;
  final String details;
  final String title;
  final String description;
  final String dateposted;
  final String project;
  final String image;
  final String image_small;

  String address = GlobalConfiguration().getString("address");

  NewsData({this.description, this.details, this.title, this.id, this.dateposted, this.project, this.image, this.image_small});

  NewsData.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'].toString(),
        details = parsedJson['details'],
        description = parsedJson['description'],
        title = parsedJson['title'],
        dateposted = parsedJson['dateposted'],
        project = parsedJson['project'],
        image = parsedJson['image'],
        image_small = parsedJson['image_small'];
}
