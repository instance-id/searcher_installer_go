import '../../services/service_locator.dart';

class NewsData {
  final String id;
  final String details;
  final String title;
  final String description;
  final String dateposted;
  final String project;
  final String icon;
  final String image;
  final String image_small;
  String _dynamicString = "false";

  bool getBool(String value) {
    return (_dynamicString != null)
        ? _dynamicString.toLowerCase() == 'true'
        : false;
  }

  bool get isDynamic => getBool(_dynamicString);

  String address = data.getString("address");

  NewsData(
      {this.description,
      this.details,
      this.title,
      this.id,
      this.dateposted,
      this.project,
      this.image,
      this.image_small,
      this.icon});

  NewsData.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'].toString(),
        details = parsedJson['details'],
        description = parsedJson['description'],
        title = parsedJson['title'],
        dateposted = parsedJson['dateposted'],
        project = parsedJson['project'],
        image = parsedJson['image'],
        image_small = parsedJson['image_small'],
        icon = parsedJson['icon'],
        _dynamicString = parsedJson['is_dynamic'];
}
