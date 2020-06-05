import 'dart:convert';

import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:faui/faui.dart';
import 'package:faui/faui_api.dart';
import 'package:faui/src/10_auth/auth_state_user.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import '../data/events/messages_event.dart';

final _log = GetIt.instance<Logger>();
final _data = GlobalConfiguration();

class DataStorage {
  static const String _LocalKey = "user";
  static const String _PrefKey = "pref";

  static void loadAppSettings() async {
    try {
      String v = await _getLocalValue(_PrefKey);
      if (v == null || v == "null") {
        _log.d("No preferences file: Creating...");
        _storeLocally(_PrefKey, jsonEncode({"debug": false}));
        v = await _getLocalValue(_PrefKey);
      }
      Map<String, dynamic> prefs = jsonDecode(v);
      _data.updateValue("debug", prefs['debug']);
      log.d('Debug Enabled: ${_data.getBool('debug')}');
      return;
    } catch (ex) {
      _log.e("Preference file cannot be created. Please contact the developer: http://github.com/instance-id/", ex);
    }
  }

  static void saveUserLocallyForSilentSignIn() {
    _storeLocally(_LocalKey, jsonEncode(FauiAuthState.user));
    _log.d("sso: saved locally");
  }

  static void deleteUserLocally() {
    _deleteLocally(_LocalKey);
    _log.d("sso: deleted locally");
  }



  static trySignInSilently(String apiKey) async {
    GetIt getIt = GetIt.instance;
    var msg = getIt.get<Message>();

    _log.d("sso: started silent sign-in");
    try {
      String v = await _getLocalValue(_LocalKey);
      if (v == null || v == "null") {
        _log.d("sso: no user stored");
        return;
      }

      FauiUser user = FauiUser.fromJson(jsonDecode(v));
      if (user == null || user.refreshToken == null) {
        _log.d("sso: no refresh token found");
        return;
      }
      user = await fauiRefreshToken(user: user, apiKey: apiKey);
      _storeLocally(_LocalKey, jsonEncode(user.toJson()));
      _data.updateValue('loginOk', true);
      _data.updateValue('showLogin', false);
      FauiAuthState.user = user;
      _log.d("sso: succeeded silent sign-in");

      return;
    } catch (ex) {
      _log.e("sso: error during silent sign-in:", ex.toString());
      _data.updateValue('loginOk', false);
      return;
    }
  }

  static _deleteLocally(String key) async {
    LocalStorageInterface prefs;
    try {
      prefs = await LocalStorage.getInstance();
      prefs.setString(key, 'null');
      _data.updateValue('loginOk', false);
    } catch (ex) {
      _log.e("sso: Error deleting from SharedPreferences Instance");
    }
  }

  static Future<String> _getLocalValue(String key) async {
    LocalStorageInterface prefs;
    try {
      prefs = await LocalStorage.getInstance();
      return prefs.getString(key);
    } catch (ex) {
      _log.e("sso: Error retrieving from SharedPreferences Instance : " + ex);
      return null;
    }
  }

  static _storeLocally(String key, String value) async {
    LocalStorageInterface prefs;
    try {
      if (key == null) throw ("sso: Error - Key is null");
      if (value == null) throw ("sso: Error - User Value is null");
      prefs = await LocalStorage.getInstance();
      if (prefs == null) throw ("sso: Error - Cannot retrieve Shared Preferences Instance");
      prefs.setString(key, value);
      if (prefs.getString(key) != value) throw ("sso: Error - Unable to verify data stored correctly");
    } catch (ex) {
      _log.e(ex);
    }
  }
}
