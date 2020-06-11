import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../data/errors/errors.dart';
import '../data/events/authstatus_event.dart';
import '../data/extension/extensions.dart';
import '../data/provider/fb_auth_provider.dart';
import '../data/provider/message_text.dart';
import '../helpers/custom_color.dart';
import '../services/service_locator.dart';
import '../widgets/constants.dart';
import '../widgets/custom_route.dart';
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
  final status = sl<AuthStatusListener>();
  final dashboardScreen = sl<DashboardScreen>();

  Future<String> doLogin(LoginData loginData, BuildContext context, bool mounted) async {
    try {
      var result = await context.read<FBAuthProvider>().signIn(loginData);
      await this.afterAuthorized(context);
      if (result == "notVerified") return result;
    } catch (e) {
      return FBError.exceptionToUiMessage(e);
    }
    return null;
  }

  Future<String> doSignup(LoginData loginData, BuildContext context, bool mounted) async {
    try {
      var result = await context.read<FBAuthProvider>().signUp(loginData);
      this.afterAuthorized(context);
      if (result == "notVerified") return result;
    } catch (e) {
      this.setState(() {
        return FBError.exceptionToUiMessage(e);
      });
    }
    return null;
  }

  Future<String> doVerifyEmail(BuildContext context, bool mounted) async {
    String result;
    try {
      result = await context.read<FBAuthProvider>().checkEmailVerification();
      this.afterAuthorized(context);
    } catch (e) {
      this.setState(() {
        return FBError.exceptionToUiMessage(e);
      });
    }
    return result;
  }

  Future<String> _recoverPassword(String _email, BuildContext context, bool mounted) async {
    try {
      await context.read<FBAuthProvider>().recoverPassword(_email);
    } catch (e) {
      this.setState(() {
        return FBError.exceptionToUiMessage(e);
      });
    }
    return null;
  }

  Future<String> afterAuthorized(BuildContext context) async {
    var user = await context.read<FBAuthProvider>().user;
    if (user != null) {
      if (user.contactEmail == null || user.contactEmail == "") {
        user.contactEmail = user.email;
      }
      data.updateValue("updateData", true);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<FBAuthProvider>(context);

    final inputBorder = BorderRadius.vertical(
      bottom: Radius.circular(5.0),
      top: Radius.circular(10.0),
    );

    return FlutterLogin(
      title: Constants.appName,
      logo: null,
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
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
        // beforeHeroFontSize: 50,
        // afterHeroFontSize: 20,
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
//          shadows: [Shadow(color: AppColors.M_YELLOW, blurRadius: 1)],
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
      onLogin: (loginData) async {
        print('Login info');
        print('Name: ${loginData.email}');
        print('Password: ${loginData.password}');
        return doLogin(loginData, context, mounted);
      },
      onSignup: (loginData) {
        print('Signup info');
        print('Name: ${loginData.email}');
        print('Password: ${loginData.password}');
        return doSignup(loginData, context, mounted);
      },
      onVerifyEmail: (loginData) {
        print('ONVERIFYEMAIL CALLBACK');
        return doVerifyEmail(context, mounted);
      },
      onSubmitAnimationCompleted: () {
        print('ON SUBMIT ANIMATION COMPLETE?');
        Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => dashboardScreen,
        ));
      },
      onRecoverPassword: (_email) {
        print('Recover password info');
        print('Name: ${_email}');
        return _recoverPassword(_email, context, mounted);
        // Show new password dialog
      },
      showDebugButtons: false,
    );
  }
}
