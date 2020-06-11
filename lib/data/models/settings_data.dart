import 'package:searcher_installer_go/services/service_locator.dart';

class SettingsData {
  final String id;
  final String bgImage;
  String _dynamicString = "false";
  String _useBG = "false";

  bool get isDynamic => getBool(_dynamicString);
  bool get useBG => getBGBool(_useBG);

  bool getBool(String value) {
    return (_dynamicString != null) ? _dynamicString.toLowerCase() == 'true' : false;
  }

  bool getBGBool(String value) {
    return (_useBG != null) ? _useBG.toLowerCase() == 'true' : false;
  }

  String address = data.getString("address");

  SettingsData({this.id, this.bgImage});

  SettingsData.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'].toString(),
        bgImage = parsedJson['bgImage'],
        _useBG = parsedJson['useBG'],
        _dynamicString = parsedJson['is_dynamic'];
}
