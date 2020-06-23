import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../data/events/auth_status_event.dart';
import '../data/events/show_dash_event.dart';
import '../data/models/dashboard_data.dart';
import '../data/provider/fb_auth_provider.dart';
import '../data/provider/message_text.dart';
import '../helpers/custom_color.dart';
import '../services/service_locator.dart';
import '../widgets/constants.dart';
import 'dashboard_screen.dart';
import 'flutter_login.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final log = sl<Logger>();
  final messageText = sl<MessageText>();
  final authStatus = sl<AuthStatusListener>();
  final dashboardScreen = sl<DashboardScreen>();
  final dashEvent = sl<ShowDashListener>();
  final dashData = sl<DashboardData>();

  @override
  Widget build(BuildContext context) {
    final inputBorder = BorderRadius.vertical(
      bottom: Radius.circular(5.0),
      top: Radius.circular(10.0),
    );

    return FlutterLogin(
      title: Constants.appName,
      messages: messageText.messages,
      theme: LoginTheme(
        primaryColor: AppColors.LIGHT_TEXT,
        accentColor: AppColors.BLUEISH,
        errorColor: Colors.deepOrange,
        pageColorLight: AppColors.BG_DARK,
        pageColorDark: AppColors.BG_DARK,
        titleStyle: TextStyle(
          color: AppColors.LIGHT_TEXT,
          letterSpacing: 4,
        ),
        bodyStyle: TextStyle(
          color: AppColors.LIGHT_TEXT,
          fontStyle: FontStyle.normal,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.none,
        ),
        bodyStyle2: TextStyle(
          color: AppColors.LIGHT_TEXT,
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.none,
        ),
        textFieldStyle: TextStyle(
          color: AppColors.M_YELLOW,
        ),
        buttonStyle: TextStyle(
          fontWeight: FontWeight.w800,
          backgroundColor: Colors.transparent,
          color: AppColors.BLUEISH,
        ),
        cardTheme: CardTheme(
          color: Color.fromRGBO(35, 47, 52, .90),
          elevation: 12,
          shadowColor: Colors.black,
          margin: EdgeInsets.only(top: 0),
          shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
        inputTheme: InputDecorationTheme(
          hintStyle: TextStyle(
            backgroundColor: Colors.blue,
            color: Colors.white,
          ),
          filled: true,
          fillColor: AppColors.BG_DARK.withOpacity(0.5),
          contentPadding: EdgeInsets.zero,
          errorStyle: TextStyle(
            backgroundColor: Colors.redAccent,
            color: Colors.white,
          ),
          labelStyle: TextStyle(fontSize: 12),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade700, width: 4),
            borderRadius: inputBorder,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade400, width: 5),
            borderRadius: inputBorder,
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700, width: 7),
            borderRadius: inputBorder,
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade400, width: 8),
            borderRadius: inputBorder,
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 5),
            borderRadius: inputBorder,
          ),
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: Colors.purple,
          backgroundColor: AppColors.SECONDARY,
          highlightColor: AppColors.ORANGE,
          elevation: 6.0,
          highlightElevation: 6.0,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      emailValidator: (value) {
        if (!value.contains('@') || !value.contains('.')) {
          return "Please ensure you have entered a valid email address.";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: (loginData) {
        print('Login info');
        print('Name: ${loginData.email}');
        print('Password: ${loginData.password}');
        return context.read<FBAuthProvider>().signIn(loginData);
      },
      onSignup: (loginData) async {
        print('Signup info');
        print('Name: ${loginData.email}');
        print('Password: ${loginData.password}');
        return context.read<FBAuthProvider>().signUp(loginData);
      },
      onVerifyEmail: (loginData) async {
        return context.read<FBAuthProvider>().checkEmailVerification();
      },
      onSubmitAnimationCompleted: () {
        print('ON SUBMIT ANIMATION COMPLETE?');
        authStatus.setStatus(AuthStatus.signedIn);
        dashEvent.setStatus(true);
      },
      onRecoverPassword: (_email) {
        print('Recover password info');
        print('Name: ${_email}');
        return context.read<FBAuthProvider>().recoverPassword(_email);
      },
      showDebugButtons: false,
    );
  }
}
