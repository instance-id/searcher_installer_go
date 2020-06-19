import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:null_widget/null_widget.dart';
import 'package:provider/provider.dart';
import 'package:transformer_page_view/transformer_page_view.dart';

import '../data/events/auth_status_event.dart';
import '../data/models/login_data.dart';
import '../data/provider/auth_state.dart';
import '../data/provider/fb_auth_provider.dart';
import '../data/provider/login_messages.dart';
import '../extensions.dart'; // ignore: unused_import
import '../helpers/custom_color.dart';
import '../services/service_locator.dart';
import '../widgets/login/src/constants.dart';
import '../widgets/login/src/dart_helper.dart';
import '../widgets/login/src/matrix.dart';
import '../widgets/login/src/paddings.dart';
import '../widgets/login/src/widget_helper.dart';
import '../widgets/login/src/widgets/animated_button.dart';
import '../widgets/login/src/widgets/animated_text.dart';
import '../widgets/login/src/widgets/animated_text_form_field.dart';
import '../widgets/login/src/widgets/custom_page_transformer.dart';
import '../widgets/login/src/widgets/expandable_container.dart';
import '../widgets/widgets/fade_in.dart';
import 'dashboard_screen.dart';

//part 'auth_card.g.dart';

class AuthCard extends StatefulWidget {
  AuthCard({
    Key key,
    this.padding = const EdgeInsets.all(0),
    this.loadingController,
    this.emailValidator,
    this.passwordValidator,
    this.onSubmitCompleted,
  }) : super(key: key);

  final EdgeInsets padding;
  final AnimationController loadingController;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;

//  final Function onSubmit;
  final Function onSubmitCompleted;

  @override
  AuthCardState createState() => AuthCardState();
}

class AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  GlobalKey _cardKey = GlobalKey();
  final authStatus = sl<AuthStatusListener>();
  final dashboardScreen = sl<DashboardScreen>();
  final log = sl<Logger>();

  var _isLoadingFirstTime = true;
  var _pageIndex = 0;
  static const cardSizeScaleEnd = .2;
  bool _isDisposed = false;

  TransformerPageController _pageController;
  AnimationController _formLoadingController;
  AnimationController _routeTransitionController;
  Animation<double> _flipAnimation;
  Animation<double> _cardSizeAnimation;
  Animation<double> _cardSize2AnimationX;
  Animation<double> _cardSize2AnimationY;
  Animation<double> _cardRotationAnimation;
  Animation<double> _cardOverlayHeightFactorAnimation;
  Animation<double> _cardOverlaySizeAndOpacityAnimation;
  dynamic handler;

  @override
  void initState() {
    super.initState();

    _pageController = TransformerPageController();

    widget.loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isLoadingFirstTime = false;
        _formLoadingController.forward();
      }
    });

    _flipAnimation = Tween<double>(begin: pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: widget.loadingController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _formLoadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1150),
      reverseDuration: Duration(milliseconds: 300),
    );

    _routeTransitionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1100),
    );

    _cardSizeAnimation = Tween<double>(begin: 1.0, end: cardSizeScaleEnd).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(0, .27272727 /* ~300ms */, curve: Curves.easeInOutCirc),
    ));
    // https://github.com/flutter/flutter/issues/42527#issuecomment-575131275
    _cardOverlayHeightFactorAnimation = Tween<double>(begin: double.minPositive, end: 1.0).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.27272727, .5 /* ~250ms */, curve: Curves.linear),
    ));
    _cardOverlaySizeAndOpacityAnimation = Tween<double>(begin: 1.0, end: 0).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.5, .72727272 /* ~250ms */, curve: Curves.linear),
    ));
    _cardSize2AnimationX = Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);
    _cardSize2AnimationY = Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);
    _cardRotationAnimation = Tween<double>(begin: 0, end: pi / 2).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1 /* ~300ms */, curve: Curves.easeInOutCubic),
    ));
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _formLoadingController?.dispose();
      _pageController?.dispose();
      _routeTransitionController?.dispose();
    }
    _isDisposed = true;
    super.dispose();
  }

  void _switchRecovery(bool recovery) {
    final auth = Provider.of<AuthState>(context, listen: false);

    auth.isRecover = recovery;
    if (recovery) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = 1;
    } else {
      _pageController.previousPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = 0;
    }
  }

  Future<void> runLoadingAnimation() {
    if (widget.loadingController.isDismissed) {
      return widget.loadingController.forward().then((_) {
        if (!_isLoadingFirstTime) {
          _formLoadingController.forward().orCancel;
        }
      });
    } else if (widget.loadingController.isCompleted) {
      return _formLoadingController.reverse().then((_) => widget.loadingController.reverse());
    }
    return Future(null);
  }

  Future<void> _forwardChangeRouteAnimation() {
    log.d('----------- _forwardChangeRouteAnimation 1');

    final isLogin = Provider.of<AuthState>(context, listen: false).isLogin;
    final isVerify = Provider.of<AuthState>(context, listen: false).isVerify;
    final deviceSize = MediaQuery.of(context).size;
    final cardSize = getWidgetSize(_cardKey);
    // add .25 to make sure the scaling will cover the whole screen
    final widthRatio = deviceSize.width / cardSize.height + ((isLogin || isVerify) ? .25 : .65);
    final heightRatio = deviceSize.height / cardSize.width + .25;

    _cardSize2AnimationX = Tween<double>(begin: 1.0, end: heightRatio / cardSizeScaleEnd).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1, curve: Curves.easeInOutCubic),
    ));
    _cardSize2AnimationY = Tween<double>(begin: 1.0, end: widthRatio / cardSizeScaleEnd).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1, curve: Curves.easeInOutCubic),
    ));

    log.d('----------- _forwardChangeRouteAnimation 2');

//    widget?.onSubmit();

    return _formLoadingController.reverse().then((_) => _routeTransitionController.forward());
  }

  void _reverseChangeRouteAnimation() {
    _routeTransitionController.reverse().then((_) => _formLoadingController.forward());
  }

  void doChangeRouteAnimation() {
    _forwardChangeRouteAnimation().then((_) {
      widget.onSubmitCompleted();
    });
  }

  void runChangeRouteAnimation() {
    if (_routeTransitionController.isCompleted) {
      _reverseChangeRouteAnimation();
    } else if (_routeTransitionController.isDismissed) {
      _forwardChangeRouteAnimation();
    }
  }

  void runChangePageAnimation() {
    final auth = Provider.of<AuthState>(context, listen: false);
    _switchRecovery(!auth.isRecover);
  }

  Widget _buildLoadingAnimator({Widget child, ThemeData theme}) {
    Widget card;
    Widget overlay;

    // loading at startup
    card = AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) => Transform(
        transform: Matrix.perspective()..rotateX(_flipAnimation.value),
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );

    // change-route transition
    overlay = Padding(
      padding: theme.cardTheme.margin,
      child: AnimatedBuilder(
        animation: _cardOverlayHeightFactorAnimation,
        builder: (context, child) => ClipPath.shape(
          shape: theme.cardTheme.shape,
          child: FractionallySizedBox(
            heightFactor: _cardOverlayHeightFactorAnimation.value,
            alignment: Alignment.topCenter,
            child: child,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.accentColor),
        ),
      ),
    );

    overlay = ScaleTransition(
      scale: _cardOverlaySizeAndOpacityAnimation,
      child: FadeTransition(
        opacity: _cardOverlaySizeAndOpacityAnimation,
        child: overlay,
      ),
    );

    return Stack(
      alignment: Alignment.center,
//      fit: StackFit.loose,
      children: <Widget>[
        card,
        Positioned.fill(child: overlay),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    Widget current = Container(
      height: deviceSize.height,
      width: deviceSize.width,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: TransformerPageView(
        physics: NeverScrollableScrollPhysics(),
        pageController: _pageController,
        itemCount: 2,
        index: _pageIndex,
        transformer: CustomPageTransformer(),
        itemBuilder: (BuildContext context, int index) {
          final child = (index == 0)
              ? _buildLoadingAnimator(
                  theme: theme,
                  child: _LoginCard(
                    key: _cardKey,
                    loadingController: _isLoadingFirstTime ? _formLoadingController : (_formLoadingController..value = 1.0),
                    emailValidator: widget.emailValidator,
                    passwordValidator: widget.passwordValidator,
                    onSwitchRecoveryPassword: () => _switchRecovery(true),
                    onSubmitCompleted: () {
                      log.d('----------- onSubmitCompleted');
                      _forwardChangeRouteAnimation().then((_) => widget.onSubmitCompleted());
                    },
                  ),
                )
              : _RecoverCard(
                  emailValidator: widget.emailValidator,
                  onSwitchLogin: () => _switchRecovery(false),
                );

          return Align(
            alignment: Alignment.center,
            child: child,
          );
        },
      ),
    );

    return AnimatedBuilder(
      animation: _cardSize2AnimationX,
      builder: (context, snapshot) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(_cardRotationAnimation.value)
            ..scale(_cardSizeAnimation.value, _cardSizeAnimation.value)
            ..scale(_cardSize2AnimationX.value, _cardSize2AnimationY.value),
          child: current,
        );
      },
    );
  }
}

class _LoginCard extends StatefulWidget {
  _LoginCard({
    Key key,
    this.loadingController,
    @required this.emailValidator,
    @required this.passwordValidator,
    @required this.onSwitchRecoveryPassword,
    this.onSwitchAuth,
    this.onSubmitCompleted,
  }) : super(key: key);

  final AnimationController loadingController;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;
  final Function onSwitchRecoveryPassword;
  final Function onSwitchAuth;
  final Function onSubmitCompleted;

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final authStatus = sl<AuthStatusListener>();
  final log = sl<Logger>();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  TextEditingController _nameController;
  TextEditingController _passController;
  TextEditingController _confirmPassController;

  var _isLoading = false;
  var _isSubmitting = false;
  var _showShadow = true;

  /// switch between login and signup
  AnimationController _loadingController;
  AnimationController _switchAuthController;
  AnimationController _postSwitchAuthController;
  AnimationController _submitController;

  Interval _nameTextFieldLoadingAnimationInterval;
  Interval _passTextFieldLoadingAnimationInterval;
  Interval _textButtonLoadingAnimationInterval;
  Animation<double> _buttonScaleAnimation;

  bool get buttonEnabled => !_isLoading && !_isSubmitting;
  bool _isDisposed = false;

  dynamic handler;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthState>(context, listen: false);

    handler = buildHandler(authStatus, context);
    authStatus.event.subscribe(handler);

    if (authStatus.status == AuthStatus.notVerified) Future.microtask(() => _switchAuthMode(verify: true));

    _nameController = TextEditingController(text: auth.email);
    _passController = TextEditingController(text: auth.password);
    _confirmPassController = TextEditingController(text: auth.confirmPassword);

    _loadingController = widget.loadingController;
    _loadingController?.addStatusListener(handleLoadingAnimationStatus);

    _switchAuthController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _postSwitchAuthController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    _submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _nameTextFieldLoadingAnimationInterval = const Interval(0, .85);
    _passTextFieldLoadingAnimationInterval = const Interval(.15, 1.0);
    _textButtonLoadingAnimationInterval = const Interval(.6, 1.0, curve: Curves.easeOut);
    _buttonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Interval(.4, 1.0, curve: Curves.easeOutBack),
    ));
  }

  buildHandler(AuthStatusListener listener, BuildContext context) {
    return (args) => () {
          switch (authStatus.status) {
            case AuthStatus.notVerified:
              showInfoToast(context, "Please verify email to continue", "Info", 4000);
              Future.microtask(() => _switchAuthMode(verify: true));
              break;
            case AuthStatus.verified:
              showSuccessToast(context, "Verification complete!", "Success:", 4000);
              authStatus.setStatus(AuthStatus.signIn);
              break;
            default:
              break;
          }
        }();
  }

  void handleLoadingAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.completed) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    if(!_isDisposed) {
      authStatus.event.unsubscribe(handler);
      _loadingController.removeStatusListener(handleLoadingAnimationStatus);
      _passwordFocusNode.dispose();
      _confirmPasswordFocusNode.dispose();

      _switchAuthController.dispose();
      _postSwitchAuthController.dispose();
      _submitController.dispose();
      _isDisposed = true;
    }
    super.dispose();
  }

  void _switchAuthMode({bool verify}) {
    final auth = Provider.of<AuthState>(context, listen: false);
    final newAuthMode = auth.switchAuth(verify: verify);

    if (newAuthMode == AuthMode.Signup) {
      _switchAuthController.forward();
    } else {
      _switchAuthController.reverse();
    }
  }

  Future<bool> _submit() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formKey.currentState.validate()) {
      return false;
    }

    _formKey.currentState.save();
    _submitController.forward();
    setState(() => _isSubmitting = true);
    final auth = Provider.of<AuthState>(context, listen: false);
    var result;

    if (auth.isLogin) {
      result = await auth.onLogin(LoginData(
        email: auth.email,
        password: auth.password,
      ));
    } else if (auth.isVerify) {
      result = await auth.onVerifyEmail(LoginData(
        email: auth.email,
        password: auth.password,
      ));
    } else {
      result = await auth.onSignup(LoginData(
        email: auth.email,
        password: auth.password,
      ));
    }

    // workaround to run after _cardSizeAnimation in parent finished
    // need a cleaner way but currently it works so..
    Future.delayed(const Duration(milliseconds: 270), () {
      if (mounted) setState(() => _showShadow = false);
    });

    _submitController.reverse();

    if (!DartHelper.isNullOrEmpty(result)) {
      if (result == "notVerified") {
        log.d("Status: Please verify email address to continue");
      } else {
        showErrorToast(context, result, "Error", 4000);
        log.e("Error: ${result}");
      }
      Future.delayed(const Duration(milliseconds: 271), () {
        setState(() => _showShadow = true);
      });
      setState(() => _isSubmitting = false);
      return false;
    }
    widget.onSubmitCompleted();
    return true;
  }

  Widget _buildVerifyEmailText(BuildContext context, double width, LoginMessages messages, AuthState auth) {
    final cacheEmail = context.read<FBAuthProvider>().cacheEmail;
    _nameController.text = cacheEmail;

    return AnimatedTextFormField(
      controller: _nameController,
      enabled: false,
      width: width,
      loadingController: _loadingController,
      interval: _nameTextFieldLoadingAnimationInterval,
      labelText: messages.usernameHint,
      prefixIcon: Icon(
        FontAwesomeIcons.solidUserCircle,
        color: AppColors.M_DYELLOW,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        _submit();
      },
    );
  }

  Widget _buildNameField(double width, LoginMessages messages, AuthState auth) {
    return AnimatedTextFormField(
      controller: _nameController,
      width: width,
      loadingController: _loadingController,
      interval: _nameTextFieldLoadingAnimationInterval,
      labelText: messages.usernameHint,
      prefixIcon: Icon(
        FontAwesomeIcons.solidUserCircle,
        color: AppColors.M_DYELLOW,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      validator: widget.emailValidator,
      onSaved: (value) => auth.email = value,
      formatter: [
        WhitelistingTextInputFormatter(RegExp(r"([a-zA-Z0-9\-\._@])")),
        BlacklistingTextInputFormatter(RegExp(r"[\r\t+]")),
      ],
    );
  }

  Widget _buildPasswordField(double width, LoginMessages messages, AuthState auth) {
    return AnimatedPasswordTextFormField(
      isPassword: true,
      animatedWidth: width,
      loadingController: _loadingController,
      interval: _passTextFieldLoadingAnimationInterval,
      labelText: messages.passwordHint,
      controller: _passController,
      textInputAction: auth.isLogin ? TextInputAction.done : TextInputAction.next,
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (value) {
        if (auth.isLogin) {
          _submit();
        } else {
          // SignUp
          FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
        }
      },
      validator: widget.passwordValidator,
      onSaved: (value) => auth.password = value,
      formatter: [
        BlacklistingTextInputFormatter(new RegExp('[\\\r\t+ ]')),
        LengthLimitingTextInputFormatter(20),
      ],
    );
  }

  Widget _buildConfirmPasswordField(double width, LoginMessages messages, AuthState auth) {
    return AnimatedPasswordTextFormField(
      isPassword: true,
      animatedWidth: width,
      enabled: auth.isSignup,
      loadingController: _loadingController,
      inertiaController: _postSwitchAuthController,
      inertiaDirection: TextFieldInertiaDirection.right,
      labelText: messages.confirmPasswordHint,
      controller: _confirmPassController,
      textInputAction: TextInputAction.done,
      focusNode: _confirmPasswordFocusNode,
      onFieldSubmitted: (value) => _submit(),
      validator: auth.isSignup
          ? (value) {
              if (value != _passController.text) {
                return messages.confirmPasswordError;
              }
              return null;
            }
          : (value) => null,
      onSaved: (value) => auth.confirmPassword = value,
      formatter: [
        BlacklistingTextInputFormatter(new RegExp('[\\\r\t+ ]')),
        LengthLimitingTextInputFormatter(20),
      ],
    );
  }

  Widget _buildForgotPassword(ThemeData theme, LoginMessages messages) {
    return FadeIn(
      controller: _loadingController,
      fadeDirection: FadeDirection.bottomToTop,
      offset: .5,
      curve: _textButtonLoadingAnimationInterval,
      child: FlatButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Text(
          messages.forgotPasswordButton,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.M_LGRAY),
          textAlign: TextAlign.left,
        ),
        onPressed: buttonEnabled
            ? () {
                // save state to populate email field on recovery card
                _formKey.currentState.save();
                widget.onSwitchRecoveryPassword();
              }
            : null,
      ),
    );
  }

  Widget _buildResendVerification(BuildContext context, ThemeData theme, LoginMessages messages) {
    final fbAuth = context.watch<FBAuthProvider>();

    return FadeIn(
      controller: _loadingController,
      fadeDirection: FadeDirection.bottomToTop,
      offset: .5,
      curve: _textButtonLoadingAnimationInterval,
      child: FlatButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Text(
          messages.resendVerificationButton,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.BLUEISH),
          textAlign: TextAlign.left,
        ),
        onPressed: buttonEnabled
            ? () {
                fbAuth.auth.requestEmailVerification().then(
                      (value) => showInfoToast(context, "Email verification message sent", "Status:", 4000),
                    );
              }
            : null,
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, LoginMessages messages, AuthState auth) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        controller: _submitController,
        text: () {
          switch (auth.mode) {
            case AuthMode.Login:
              return messages.loginButton;
              break;
            case AuthMode.Signup:
              return messages.signupButton;
              break;
            case AuthMode.Verify:
              return messages.verifyEmailButton;
              break;
            default:
          }
        }(),
        onPressed: _submit,
      ),
    );
  }

  Widget _buildSwitchAuthButton(ThemeData theme, LoginMessages messages, AuthState auth) {
    return FadeIn(
      controller: _loadingController,
      offset: .5,
      curve: _textButtonLoadingAnimationInterval,
      fadeDirection: FadeDirection.topToBottom,
      child: FlatButton(
        child: AnimatedText(
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.M_LGRAY),
          text: auth.isSignup ? messages.loginButton : messages.signupButton,
          textRotation: AnimatedTextRotation.down,
        ),
        disabledTextColor: theme.primaryColor,
        onPressed: buttonEnabled ? () => _switchAuthMode(verify: false) : null,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthState>(context, listen: true);
    final isSignup = auth.isSignup;
    final isVerify = auth.isVerify;
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min(deviceSize.width * 0.75, 460.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    final authForm = Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: cardPadding,
              right: cardPadding,
              top: cardPadding,
            ),
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                (isVerify) ? _buildVerifyEmailText(context, textFieldWidth, messages, auth) : _buildNameField(textFieldWidth, messages, auth),
                SizedBox(height: 20),
                (isVerify)
                    ? Text(
                        messages.verifyEmailLabel,
                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.M_LGRAY),
                        textAlign: TextAlign.left,
                      )
                    : _buildPasswordField(textFieldWidth, messages, auth),
                SizedBox(height: 10),
              ],
            ),
          ),
          ExpandableContainer(
            backgroundColor: theme.accentColor,
            controller: _switchAuthController,
            initialState: isSignup ? ExpandableContainerState.expanded : ExpandableContainerState.shrunk,
            alignment: Alignment.topLeft,
            color: theme.cardTheme.color,
            width: cardWidth,
            padding: EdgeInsets.symmetric(
              horizontal: cardPadding,
              vertical: 10,
            ),
            onExpandCompleted: () => _postSwitchAuthController.forward(),
            child: _buildConfirmPasswordField(textFieldWidth, messages, auth),
          ),
          Container(
            padding: Paddings.fromRBL(cardPadding),
            width: cardWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                (isVerify)
                    ? Container(width: 130, child: NullWidget())
                    : Container(
                        width: 130,
                        child: _buildSwitchAuthButton(theme, messages, auth),
                      ),
                Align(
                  alignment: Alignment.center,
                  child: _buildSubmitButton(theme, messages, auth),
                ),
                (isVerify)
                    ? Container(width: 130, child: _buildResendVerification(context, theme, messages))
                    : Container(
                        width: 130,
                        child: _buildForgotPassword(theme, messages),
                      ),
              ],
            ),
          ),
        ],
      ),
    );

    return FittedBox(
      child: Card(
        elevation: _showShadow ? theme.cardTheme.elevation : 0,
        child: authForm,
      ),
    );
  }
}

class _RecoverCard extends StatefulWidget {
  _RecoverCard({
    Key key,
    this.messages,
    @required this.emailValidator,
    @required this.onSwitchLogin,
  }) : super(key: key);

  final LoginMessages messages;
  final FormFieldValidator<String> emailValidator;
  final Function onSwitchLogin;

  @override
  _RecoverCardState createState() => _RecoverCardState();
}

class _RecoverCardState extends State<_RecoverCard> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();
  TextEditingController _nameController;

  var _isSubmitting = false;

  AnimationController _submitController;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthState>(context, listen: false);
    _nameController = new TextEditingController(text: auth.email);

    _submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _submitController.dispose();
  }

  Future<bool> _submit() async {
    if (!_formRecoverKey.currentState.validate()) {
      return false;
    }
    final auth = Provider.of<AuthState>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _formRecoverKey.currentState.save();
    _submitController.forward();
    setState(() => _isSubmitting = true);
    final error = await auth.onRecoverPassword(auth.email);

    if (error != null) {
      showErrorToast(context, error, "Error", 4000);
      setState(() => _isSubmitting = false);
      _submitController.reverse();
      return false;
    } else {
      showSuccessToast(context, messages.recoverPasswordSuccess, "Success:", 4000);
      setState(() => _isSubmitting = false);
      _submitController.reverse();
      return true;
    }
  }

  Widget _buildRecoverNameField(double width, LoginMessages messages, AuthState auth) {
    return AnimatedTextFormField(
      controller: _nameController,
      width: width,
      labelText: messages.usernameHint,
      prefixIcon: Icon(FontAwesomeIcons.solidUserCircle),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submit(),
      validator: widget.emailValidator,
      onSaved: (value) => auth.email = value,
    );
  }

  Widget _buildRecoverButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.recoverPasswordButton,
      onPressed: !_isSubmitting ? _submit : null,
    );
  }

  Widget _buildBackButton(ThemeData theme, LoginMessages messages) {
    return FlatButton(
      child: Text(messages.goBackButton),
      onPressed: !_isSubmitting
          ? () {
              _formRecoverKey.currentState.save();
              widget.onSwitchLogin();
            }
          : null,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: theme.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthState>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;

    return FittedBox(
      // width: cardWidth,
      child: Card(
        child: Container(
          padding: const EdgeInsets.only(
            left: cardPadding,
            top: cardPadding + 10.0,
            right: cardPadding,
            bottom: cardPadding,
          ),
          width: cardWidth,
          alignment: Alignment.center,
          child: Form(
            key: _formRecoverKey,
            child: Column(
              children: <Widget>[
                Text(
                  messages.recoverPasswordIntro,
                  key: kRecoverPasswordIntroKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.body1,
                ),
                SizedBox(height: 20),
                _buildRecoverNameField(textFieldWidth, messages, auth),
                SizedBox(height: 20),
                Text(
                  messages.recoverPasswordDescription,
                  key: kRecoverPasswordDescriptionKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.body1,
                ),
                SizedBox(height: 26),
                _buildRecoverButton(theme, messages),
                _buildBackButton(theme, messages),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
