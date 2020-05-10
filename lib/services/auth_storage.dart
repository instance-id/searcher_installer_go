import 'dart:convert';

import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:faui/faui_api.dart';
import 'package:faui/src/10_auth/auth_state_user.dart';
import 'package:faui/faui.dart';
import 'package:global_configuration/global_configuration.dart';

class AuthStorage {
  final api = GlobalConfiguration();
  static const String _LocalKey = "user";

  static void saveUserLocallyForSilentSignIn() {
    _storeLocally(_LocalKey, jsonEncode(FauiAuthState.user));
    print("sso: saved locally");
  }

  static void deleteUserLocally() {
    _deleteLocally(_LocalKey);
    print("sso: deleted locally");
  }

  static trySignInSilently(String apiKey) async {
    final api = GlobalConfiguration();
    print("sso: started silent sign-in");
    try {
      String v = await _getLocalValue(_LocalKey);
      if (v == null || v == "null") {
        print("sso: no user stored");
        return;
      }

      FauiUser user = FauiUser.fromJson(jsonDecode(v));
      if (user == null || user.refreshToken == null) {
        print("sso: no refresh token found");
        return;
      }
      user = await fauiRefreshToken(user: user, apiKey: apiKey);
      _storeLocally(_LocalKey, jsonEncode(user));
      api.updateValue('loginOk', true);
      api.updateValue('showLogin', false);
      FauiAuthState.user = user;
      print("sso: succeeded silent sign-in");
      return;
    } catch (ex) {
      print("sso: error during silent sign-in:");
      print(ex.toString());
      api.updateValue('loginOk', false);
      return;
    }
  }

  static _deleteLocally(String key) async {
    final api = GlobalConfiguration();
    LocalStorageInterface prefs;
    try {
      prefs = await LocalStorage.getInstance();
      prefs.setString(key, 'null');
      api.updateValue('loginOk', false);
    } catch (ex) {
      print("sso: Error deleting from SharedPreferences Instance");
    }
  }

  static Future<String> _getLocalValue(String key) async {
    LocalStorageInterface prefs;
    try {
      prefs = await LocalStorage.getInstance();
      return prefs.getString(key);
    } catch (ex) {
      print("sso: Error retrieving from SharedPreferences Instance : " + ex);
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
      print(ex);
    }
  }
}
