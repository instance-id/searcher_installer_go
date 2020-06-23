import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/firestore/models.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../extensions.dart'; // ignore: unused_import
import '../../services/service_locator.dart';
import '../provider/fb_auth_provider.dart';

class DashboardData {
  final log = sl<Logger>();

  // -- Declarations -----------------------------------------------------
  dynamic _document;
  DocumentReference _ref;
  FBAuthProvider fbAuthProvider;
  TextEditingController _firstCtrl;
  TextEditingController _lastCtrl;
  TextEditingController _serialNum;
  TextEditingController _contactEmail;
  User _user;

  // -- Getters ----------------------------------------------------------
  Document get document => _document;
  DocumentReference get ref => _ref;
  TextEditingController get firstCtrl => _firstCtrl;
  TextEditingController get lastCtrl => _lastCtrl;
  TextEditingController get serialNum => _serialNum;
  TextEditingController get contactEmail => _contactEmail;
  User get user => _user;

  // -- Setters ----------------------------------------------------------
  set document(value) => _document = value;
  set contactEmail(TextEditingController value) => _contactEmail = value;
  set firstCtrl(TextEditingController value) => _firstCtrl = value;
  set lastCtrl(TextEditingController value) => _lastCtrl = value;
  set ref(DocumentReference value) => _ref = value;
  set serialNum(TextEditingController value) => _serialNum = value;
  set user(User value) => _user = value;

  init() {
    document = null;
    ref = null;
    _firstCtrl = TextEditingController();
    _lastCtrl = TextEditingController();
    _serialNum = TextEditingController();
    _contactEmail = TextEditingController();
  }

  Future<void> loadData() async {
    if (data.getBool("updateData")) {
      data.updateValue("updateData", false);
      fbAuthProvider.getDocument();
      document ??= {
        "first": "",
        "last": "",
        "serialNum": "",
        "contactEmail": user.email,
      };

      _firstCtrl.text = user.fname = document["first"];
      _lastCtrl.text = user.lname = document["last"];
      _serialNum.text = user.serialNum = document["serialNum"];
      user.verified = document["verified"];

      // @formatter:off
      (document["contactEmail"] == null || document["contactEmail"] == "")
          ? _contactEmail.text = user.contactEmail = user.email
          : _contactEmail.text = user.contactEmail = document["contactEmail"];

      if (data.getBool("debug")) log.d('Data Loaded : Firebase;');

      data.updateValue("verified", verificationCheck(user));
    } else {
      _firstCtrl.text = user.fname ?? "";
      _lastCtrl.text = user.lname ?? "";
      _serialNum.text = user.serialNum ?? "";
      _contactEmail.text = user.contactEmail ?? user.email;

      if (data.getBool("debug")) log.d('Data Loaded : Local;');
    }
  }

  String verificationCheck(User user) {
    bool v = user.verified;
    if (data.getBool("debug")) log.d('Verified? ${v}');
    return (v) ? "Verified" : "Not Verified";
  }

  clearData() async {
    ref.stream.listen((event) {}).cancel();
    ref = null;
    user = null;
    document = null;
    firstCtrl.text = "";
    lastCtrl.text = "";
    serialNum.text = "";
    contactEmail.text = "";
  }
}
