import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../data/events/auth_status_event.dart';
import '../data/provider/auth_state.dart';
import '../data/provider/login_messages.dart';
import '../data/provider/login_theme.dart';
import '../extensions.dart'; // ignore: unused_import
import '../services/service_locator.dart';
import '../widgets/login/src/color_helper.dart';
import '../widgets/login/src/constants.dart';
import '../widgets/login/src/regex.dart';
import '../widgets/login/theme.dart';
import 'auth_card.dart';
import 'dashboard_screen.dart';

export '../data/models/login_data.dart';
export '../data/provider/login_theme.dart';

class FlutterLogin extends StatefulWidget {
  FlutterLogin({
    Key key,
    @required this.onSignup,
    @required this.onLogin,
    @required this.onVerifyEmail,
    @required this.onRecoverPassword,
    this.title = 'LOGIN',
    this.logo,
    this.messages,
    this.theme,
    this.emailValidator,
    this.passwordValidator,
    this.onSubmitAnimationCompleted,
//    this.logoTag,
//    this.titleTag,
    this.showDebugButtons = false,
  }) : super(key: key);

  /// Called when the user hit the submit button when in sign up mode
  final AuthCallback onSignup;

  /// Called when the user hit the submit button when in verify email mode
  final AuthCallback onVerifyEmail;

  /// Called when the user hit the submit button when in login mode
  final AuthCallback onLogin;

  /// Called when the user hit the submit button when in recover password mode
  final RecoverCallback onRecoverPassword;

  /// The large text above the login [Card], usually the app or company name
  final String title;

  /// The path to the asset image that will be passed to the `Image.asset()`
  final String logo;

  /// Describes all of the labels, text hints, button texts and other auth
  /// descriptions
  final LoginMessages messages;

  /// FlutterLogin's theme. If not specified, it will use the default theme as
  /// shown in the demo gifs and use the colorsheme in the closest `Theme`
  /// widget
  final LoginTheme theme;

  /// Email validating logic, Returns an error string to display if the input is
  /// invalid, or null otherwise
  final FormFieldValidator<String> emailValidator;

  /// Same as [emailValidator] but for password
  final FormFieldValidator<String> passwordValidator;

  /// Called after the submit animation's completed. Put your route transition
  /// logic here. Recommend to use with [logoTag] and [titleTag]
  final Function onSubmitAnimationCompleted;

  /// Display the debug buttons to quickly forward/reverse login animations. In
  /// release mode, this will be overrided to false regardless of the value
  /// passed in
  final bool showDebugButtons;

  static final FormFieldValidator<String> defaultEmailValidator = (value) {
    if (value.isEmpty || !Regex.email.hasMatch(value)) {
      return 'Invalid email!';
    }
    return null;
  };

  static final FormFieldValidator<String> defaultPasswordValidator = (value) {
    if (value.isEmpty || value.length <= 2) {
      return 'Password is too short!';
    }
    return null;
  };

  @override
  _FlutterLoginState createState() => _FlutterLoginState();
}

class _FlutterLoginState extends State<FlutterLogin> with TickerProviderStateMixin {
  final GlobalKey<AuthCardState> authCardKey = GlobalKey();
  final authStatus = sl<AuthStatusListener>();
  final dashboardScreen = sl<DashboardScreen>();
  final log = sl<Logger>();
  bool _isDisposted = false;

  static const loadingDuration = const Duration(milliseconds: 275);
  AnimationController _loadingController;
  bool runOnce = true;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    );

    if (!_isDisposted)
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_isDisposted) _loadingController.forward().orCancel;
      });
  }

  @override
  void dispose() {
    if (!_isDisposted) _loadingController.dispose();
    _isDisposted = true;
    super.dispose();
  }

  ThemeData _mergeTheme({ThemeData theme, LoginTheme loginTheme}) {
    final originalPrimaryColor = loginTheme.primaryColor ?? theme.primaryColor;
    final primaryDarkShades = getDarkShades(originalPrimaryColor);
    final primaryColor = primaryDarkShades.length == 1 ? lighten(primaryDarkShades.first) : primaryDarkShades.first;
    final primaryColorDark = primaryDarkShades.length >= 3 ? primaryDarkShades[2] : primaryDarkShades.last;
    final accentColor = loginTheme.accentColor ?? theme.accentColor;
    final errorColor = loginTheme.errorColor ?? theme.errorColor;
    // the background is a dark gradient, force to use white text if detect default black text color
    final isDefaultBlackText = theme.textTheme.headline3.color == Typography.blackMountainView.headline3.color;
    final titleStyle = theme.textTheme.headline3
        .copyWith(
          color: loginTheme.accentColor ?? (isDefaultBlackText ? Colors.white : theme.textTheme.headline3.color),
          fontSize: loginTheme.beforeHeroFontSize,
          fontWeight: FontWeight.w300,
        )
        .merge(loginTheme.titleStyle);
    final textStyle = theme.textTheme.body1.copyWith(color: Colors.black54).merge(loginTheme.bodyStyle);
    final textFieldStyle = theme.textTheme.subhead.copyWith(color: Colors.black.withOpacity(.65), fontSize: 14).merge(loginTheme.textFieldStyle);
    final buttonStyle = theme.textTheme.button.copyWith(color: Colors.white).merge(loginTheme.buttonStyle);
    final cardTheme = loginTheme.cardTheme;
    final inputTheme = loginTheme.inputTheme;
    final buttonTheme = loginTheme.buttonTheme;
    final roundBorderRadius = BorderRadius.circular(100);

    LoginThemeHelper.loginTextStyle = titleStyle;

    return theme.copyWith(
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
      accentColor: accentColor,
      errorColor: errorColor,
      backgroundColor: Colors.transparent,
      scaffoldBackgroundColor: Colors.transparent,
      cardTheme: theme.cardTheme.copyWith(
        clipBehavior: cardTheme.clipBehavior,
        color: cardTheme.color ?? theme.cardColor,
        elevation: cardTheme.elevation ?? 12.0,
        margin: cardTheme.margin ?? const EdgeInsets.all(4.0),
        shape: cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: inputTheme.filled,
        fillColor: inputTheme.fillColor ??
            Color.alphaBlend(
              primaryColor.withOpacity(.07),
              Colors.grey.withOpacity(.04),
            ),
        contentPadding: inputTheme.contentPadding ?? const EdgeInsets.symmetric(vertical: 4.0),
        errorStyle: inputTheme.errorStyle ?? TextStyle(color: errorColor),
        labelStyle: inputTheme.labelStyle,
        enabledBorder: inputTheme.enabledBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: roundBorderRadius,
            ),
        focusedBorder: inputTheme.focusedBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        errorBorder: inputTheme.errorBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor),
              borderRadius: roundBorderRadius,
            ),
        focusedErrorBorder: inputTheme.focusedErrorBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        disabledBorder: inputTheme.disabledBorder ?? inputTheme.border,
      ),
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        backgroundColor: buttonTheme?.backgroundColor ?? primaryColor,
        splashColor: buttonTheme.splashColor ?? theme.accentColor,
        elevation: buttonTheme.elevation ?? 4.0,
        highlightElevation: buttonTheme.highlightElevation ?? 2.0,
        shape: buttonTheme.shape ?? StadiumBorder(),
      ),
      // put it here because floatingActionButtonTheme doesnt have highlightColor property
      highlightColor: loginTheme.buttonTheme.highlightColor ?? theme.highlightColor,
      textTheme: theme.textTheme.copyWith(
        headline3: titleStyle,
        bodyText2: textStyle,
        subtitle1: textFieldStyle,
        button: buttonStyle,
      ),
    );
  }

  //region Debug Buttons
  Widget _buildDebugAnimationButtons(BuildContext context) {
    const textStyle = TextStyle(fontSize: 12, color: Colors.white);

    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          right: 0,
          child: Row(
            key: kDebugToolbarKey,
            children: <Widget>[
              RaisedButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.blue,
                child: Text('LOADING', style: textStyle),
                onPressed: () => authCardKey.currentState.runLoadingAnimation(),
              ),
              RaisedButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.orange,
                child: Text('PAGE', style: textStyle),
                onPressed: () => authCardKey.currentState.runChangePageAnimation(),
              ),
              RaisedButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.red,
                child: Text('NAV', style: textStyle),
                onPressed: () => authCardKey.currentState.runChangeRouteAnimation(),
              ),
            ],
          ),
        ),
      ],
    );
  }

//endregion

  @override
  Widget build(BuildContext context) {
    final loginTheme = widget.theme ?? LoginTheme();
    final theme = _mergeTheme(theme: Theme.of(context), loginTheme: loginTheme);
    final emailValidator = widget.emailValidator ?? FlutterLogin.defaultEmailValidator;
    final passwordValidator = widget.passwordValidator ?? FlutterLogin.defaultPasswordValidator;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: widget.messages ?? LoginMessages(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthState(
            onLogin: widget.onLogin,
            onSignup: widget.onSignup,
            onVerifyEmail: widget.onVerifyEmail,
            onRecoverPassword: widget.onRecoverPassword,
          ),
        ),
      ],
      child: Material(
        type: MaterialType.transparency,
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
            child: FluidLayout(
              horizontalPadding: FluidValue((_) => 0),
              child: Fluid(
                child: Theme(
                  data: theme,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    height: MediaQuery.of(context).size.height - 122,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 20,
                          child: AuthCard(
                            key: authCardKey,
                            loadingController: _loadingController,
                            emailValidator: emailValidator,
                            passwordValidator: passwordValidator,
                            onSubmitCompleted: widget.onSubmitAnimationCompleted,
                          ),
                        ),
                        if (!kReleaseMode && widget.showDebugButtons)
                          Flexible(flex: 1, child: _buildDebugAnimationButtons(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
