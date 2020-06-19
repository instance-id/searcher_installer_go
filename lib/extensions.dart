import 'package:firedart/auth/user_gateway.dart';

// region String Extension
extension StringNullCheck on String {
  bool get isNullOrEmpty => this == '' || this == null;
}
// endregion

// region Firebase User class
class FBUserData {
  String _fname;
  String _lname;
  String _serialNum;
  String _contactEmail;
  String _verified;
}

extension FBUser on User {
  static FBUserData u = FBUserData();

  String get fname => u._fname;

  String get lname => u._lname;

  String get serialNum => u._serialNum;

  String get contactEmail => u._contactEmail;

  dynamic get verified => getBool(u._verified);

  bool getBool(String value) {
    return (u._verified != null) ? u._verified.toLowerCase() == 'true' : false;
  }

  set fname(String value) {
    u._fname = value;
  }

  set lname(String value) {
    u._lname = value;
  }

  set serialNum(String value) {
    u._serialNum = value;
  }

  set contactEmail(String value) {
    u._contactEmail = value;
  }

  set verified(bool value) {
    u._verified = value.toString();
  }
}
// endregion
