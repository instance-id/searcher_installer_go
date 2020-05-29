import 'package:faui/faui.dart';
import 'package:faui/faui_api.dart';
import 'package:faui/src/10_auth/auth_state_user.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer_go/data/provider/auth_provider.dart';
import 'package:searcher_installer_go/data/provider/login_messages.dart';
import 'package:searcher_installer_go/services/data_storage.dart';

import '../data/enums/enums.dart';
import '../helpers/custom_color.dart';
import '../widgets/constants.dart';
import '../widgets/custom_route.dart';
import 'dashboard_screen.dart';
import 'flutter_login.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  var data = GlobalConfiguration();
  Logger log = Logger();

  Future<String> doLogin(LoginData loginData, BuildContext context, bool mounted) async {
    try {
      FauiUser fauiUser = await fauiSignInUser(
        apiKey: data.getString('apiKey'),
        email: loginData.email,
        password: loginData.password,
      );

      this.afterAuthorized(context, fauiUser);
    } catch (e) {
       return FauiError.exceptionToUiMessage(e);
    }
    return null;
  }

  Future<String> doSignup(LoginData loginData, BuildContext context, bool mounted) async {
    try {
      FauiUser fauiUser = await fauiRegisterUser(
        apiKey: data.getString('apiKey'),
        email: loginData.email,
        password: loginData.password,
        sendResetLink: false,
      );

      this.afterAuthorized(context, fauiUser);
    } catch (e) {
      this.setState(() {
        return FauiError.exceptionToUiMessage(e);
      });
    }
    return null;
  }

  Future<String> _recoverPassword(String _email, BuildContext context, bool mounted) async {
    try {
      await fauiSendResetLink(
        apiKey: data.getString('apiKey'),
        email: _email,
      );
    } catch (e) {
      this.setState(() {
        return FauiError.exceptionToUiMessage(e);
      });
    }
    return null;
  }

  Future<String> afterAuthorized(BuildContext context, FauiUser user) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    FauiAuthState.user = user;
//    authProvider.doAuthChange(AuthStatus.signedIn);
    if (fauiUser != null || fauiUser != 'null') {
      if (FauiAuthState.user.contactEmail == null || FauiAuthState.user.contactEmail == "") {
        FauiAuthState.user.contactEmail = FauiAuthState.user.email;
      }
      DataStorage.saveUserLocallyForSilentSignIn();
      data.updateValue("updateData", true);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final inputBorder = BorderRadius.vertical(
      bottom: Radius.circular(5.0),
      top: Radius.circular(10.0),
    );

    return FlutterLogin(
      title: Constants.appName,
      logo: null,
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
      messages: LoginMessages(
        usernameHint: 'Email Address',
        passwordHint: 'Password',
        confirmPasswordHint: 'Confirm',
        loginButton: 'Login',
        signupButton: 'Register',
        forgotPasswordButton: 'Reset Password',
        recoverPasswordButton: 'Reset!',
        goBackButton: 'Go Back',
        confirmPasswordError: 'Not matching!',
        recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
        recoverPasswordDescription: 'To reset your password, please enter your email address.',
        recoverPasswordSuccess: 'Password reset request has been sent.',
      ),
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
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          // shape: CircleBorder(side: BorderSide(color: Colors.green)),
          // shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(55.0)),
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
        return doLogin(loginData, context, mounted);
      },
      onSignup: (loginData) {
        print('Signup info');
        print('Name: ${loginData.email}');
        print('Password: ${loginData.password}');
        return doSignup(loginData, context, mounted);
      },
      onSubmitAnimationCompleted: () {
        auth.doAuthChange(AuthStatus.signedIn);

        Navigator.of(context).push(FadePageRoute(
          builder: (context) => DashboardScreen(),
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
