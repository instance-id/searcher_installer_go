import 'dart:math' as math;

import 'package:faui/faui.dart';
import 'package:faui/src/10_auth/auth_state_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:getflutter/colors/gf_color.dart';
import 'package:getflutter/components/tabs/gf_segment_tabs.dart';
import 'package:getflutter/components/tabs/gf_tabbar_view.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:guard/guard.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:searcher_installer_go/animations/slide_in.dart';
import 'package:searcher_installer_go/data/provider/auth_provider.dart';
import 'package:searcher_installer_go/helpers/custom_card.dart';
import 'package:searcher_installer_go/helpers/custom_color.dart';
import 'package:searcher_installer_go/routes/login_screen.dart';
import 'package:searcher_installer_go/services/auth_storage.dart';
import 'package:searcher_installer_go/widgets/transition_route_observer.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:sized_context/sized_context.dart';
import 'package:supercharged/supercharged.dart';

import '../widgets/constants.dart';
import '../widgets/login/widgets.dart';
import '../widgets/widgets/animated_numeric_text.dart';
import '../widgets/widgets/fade_in.dart';
import '../widgets/widgets/round_button.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin, TransitionRouteAware {
  var log = Logger();
  FauiDb fauiDb;
  final data = GlobalConfiguration();
  String _collection;
  bool updateData;

  Future<bool> _goToLogin(BuildContext context, FauiUser fauiUser) {
    log.i("Logging Out");
    _doc = null;
    AuthStorage.deleteUserLocally();
    FauiAuthState.user = null;
    data.updateValue("showLogin", true);
    return Navigator.of(context).pushReplacementNamed(LoginScreen.routeName).then((_) => false);
  }

  final routeObserver = TransitionRouteObserver<PageRoute>();
  static const headerAniInterval = const Interval(.1, .3, curve: Curves.easeOut);
  Animation<double> _headerScaleAnimation;
  AnimationController _loadingController;
  TextEditingController _firstCtrl = TextEditingController();
  TextEditingController _lastCtrl = TextEditingController();
  TextEditingController _serialNum = TextEditingController();
  TextEditingController _contactEmail = TextEditingController();
  Map<String, dynamic> _doc;
  bool _debug = false;

  double parentHeight;
  double parentwidth;
  TabController tabController;
  bool isDisposed = false;

  @override
  void initState() {
    _collection = data.getString('collection');
    updateData = data.getBool("updateData");
    _debug = data.getBool("debug");
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    fauiDb = authProvider.fauiDb;

    if (data.getBool("showLogin")) data.updateValue("showLogin", false);

    if (fauiUser != null || fauiUser != 'null') {
      _loadData();
    }

    if (!isDisposed) {
      tabController = TabController(length: 3, vsync: this);

      _loadingController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1250),
      );

      _headerScaleAnimation = Tween<double>(begin: .6, end: 1).animate(CurvedAnimation(
        parent: _loadingController,
        curve: headerAniInterval,
      ));

      tabController.animateTo(1);
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    if (!isDisposed) {
      routeObserver.unsubscribe(this);
      tabController.dispose();
      _loadingController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    if (updateData) {
      _doc = await FauiDbAccess(fauiDb, fauiUser.token).loadDoc(
            _collection,
            fauiUser.userId,
          ) ??
          {"first": "", "last": "", "serialNum": "", "contactEmail": fauiUser.email};

      _firstCtrl.text = fauiUser.fname = _doc["first"];
      _lastCtrl.text = fauiUser.lname = _doc["last"];
      _serialNum.text = fauiUser.serialNum = _doc["serialNum"];
      fauiUser.verified = _doc["verified"];

      // @formatter:off
      (_doc["contactEmail"] == null || _doc["contactEmail"] == "") ? _contactEmail.text = fauiUser.contactEmail = fauiUser.email : _contactEmail.text = fauiUser.contactEmail = _doc["contactEmail"];

      log.i('Data Loaded : Firebase;');
      data.updateValue("updateData", false);
      data.updateValue("verified", verificationCheck(fauiUser));
      setState(() {});
    } else {
      _firstCtrl.text = fauiUser.fname ?? "";
      _lastCtrl.text = fauiUser.lname ?? "";
      _serialNum.text = fauiUser.serialNum ?? "";
      _contactEmail.text = fauiUser.contactEmail ?? fauiUser.email;

      log.i('Data Loaded : Local;');
    }
  }

  Future<void> _saveData() async {
    _doc = {
      "first": fauiUser.fname = _firstCtrl.text,
      "last": fauiUser.lname = _lastCtrl.text,
      "serialNum": fauiUser.serialNum = _serialNum.text,
      "contactEmail": fauiUser.contactEmail = _contactEmail.text,
    };

    await FauiDbAccess(fauiDb, fauiUser.token).saveDoc(
      _collection,
      fauiUser.userId,
      _doc,
    );
    log.i('UserId: ${fauiUser.userId}');
    setState(() => {});
  }

  @override
  void didPushAfterTransition() => _loadingController.forward().orCancel;

  String verificationCheck(FauiUser fauiUser) {
    bool v = fauiUser.verified;
    log.i('Verified? ${v}');
    return (v) ? "Verified" : "Not Verified";
  }

  Widget headerType(ThemeData theme) {
    final primaryColor = Colors.orange;
    final accentColor = AppColors.BLUEISH;
    var loginOk = data.getBool('loginOk');
    if (!loginOk)
      return HeroText(
        "${Constants.appName}",
        tag: Constants.titleTag,
        viewState: ViewState.shrunk,
        style: theme.textTheme.headline2.copyWith(
          fontWeight: FontWeight.w300,
          color: accentColor,
          fontSize: 26,
        ),
      );
    if (loginOk)
      return Text(
        "${Constants.appName}",
        style: theme.textTheme.headline2.copyWith(
          shadows: [Shadow(color: AppColors.BG_DARK, blurRadius: 2)],
          fontWeight: FontWeight.w600,
          color: accentColor,
          fontSize: 36,
        ),
      );
    return Text(
      "${Constants.appName}",
      style: theme.textTheme.headline2.copyWith(
        fontWeight: FontWeight.w300,
        color: accentColor,
        fontSize: 26,
      ),
    );
  }

  // @override
  Widget _buildAppBar(ThemeData theme, fauiUser) {
    final signOutBtn = Stack(alignment: Alignment.center, children: [
      Positioned(
        left: 11.1,
        top: 12.1,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          hoverColor: Color.fromRGBO(255, 110, 64, 0.6),
          child: Transform.rotate(
              angle: 180 * math.pi / 180,
              child: Icon(
                Ionicons.md_log_out,
                color: Color.fromRGBO(35, 35, 35, 0.9),
                size: 35,
              )),
          onTap: () => _goToLogin(context, fauiUser),
        ),
      ),
      InkWell(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        hoverColor: Color.fromRGBO(255, 110, 64, 0.6),
        child: Transform.rotate(
            angle: 180 * math.pi / 180,
            child: Icon(
              Ionicons.md_log_out,
              color: AppColors.BLUEISH,
              size: 35,
            )),
//      color: theme.accentColor,
        onTap: () => _goToLogin(context, fauiUser),
      )
    ]);

    return AppBar(
      leading: FadeIn(
        controller: _loadingController,
        offset: .3,
        curve: headerAniInterval,
        fadeDirection: FadeDirection.endToStart,
        child: signOutBtn,
      ),
      title: headerType(theme),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      textTheme: theme.accentTextTheme,
      iconTheme: theme.accentIconTheme,
    );
  }

  Widget _buildHeader(ThemeData theme, FauiUser fauiUser, BuildContext context) {
    final primaryColor = Colors.orange;
    final accentColor = Colors.deepOrangeAccent;
    final linearGradient = LinearGradient(colors: [
      primaryColor.shade800,
      primaryColor.shade200,
    ]).createShader(Rect.fromLTWH(0.0, 0.0, 418.0, 78.0));

    return ScaleTransition(
      alignment: Alignment.center,
      scale: _headerScaleAnimation,
      child: FadeIn(
        controller: _loadingController,
        curve: headerAniInterval,
        fadeDirection: FadeDirection.bottomToTop,
        offset: .5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome ${guard(() => fauiUser?.displayName, 'Guest')}, ',
                  style: theme.textTheme.headline4.copyWith(
                    fontWeight: FontWeight.w300,
                    color: accentColor.shade400,
                    fontSize: 26,
                  ),
                ),
                AnimatedNumericText(
                  initialValue: 14,
                  targetValue: 4187,
                  curve: Interval(0, 1, curve: Curves.easeOut),
                  controller: _loadingController,
                  style: theme.textTheme.headline4.copyWith(
                    foreground: Paint()..shader = linearGradient,
                    backgroundColor: Colors.transparent,
                    fontSize: 26,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  ' ${_firstCtrl.text}, ${_lastCtrl.text}.',
                  style: theme.textTheme.headline4.copyWith(
                    fontWeight: FontWeight.w300,
                    color: accentColor.shade400,
                    fontSize: 26,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton({Widget icon, String label, Interval interval, double size, AnimationController loadingController, onPressed}) {
    return RoundButton(
      icon: icon,
      label: label,
      loadingController: loadingController ?? _loadingController,
      interval: Interval(
        interval.begin,
        interval.end,
        curve: ElasticOutCurve(0.42),
      ),
      onPressed: onPressed,
      size: size,
    );
  }

  final _slideLeft = MultiTween<AniProps>() // <-- design tween
    ..add(AniProps.offset, 0.0.tweenTo(400.0), 1000.milliseconds)
    ..add(AniProps.width, 400.0.tweenTo(300.0), 1000.milliseconds);

  final _slideRight = MultiTween<AniProps>() // <-- design tween
    ..add(AniProps.offset, 0.0.tweenTo(400.0), 1000.milliseconds)
    ..add(AniProps.width, 400.0.tweenTo(300.0), 1000.milliseconds);

  Widget _getSettingsPage(BuildContext context, FauiUser fauiUser, ThemeData theme) {
    const step = 0.04;
    const aniInterval = 0.75;
    parentHeight = context.heightPx;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeIn(
//              controller: _loadingController,
              curve: Interval(.7, 1, curve: Curves.easeOut),
              fadeDirection: FadeDirection.topToBottom,
              offset: .5,
              duration: 700.milliseconds,
              child: CustomCard(
                elevation: 5,
                shadowColor: Colors.black,
                color: Color.fromRGBO(35, 47, 52, 0.8),
                roundness: 10,
                borderRadius: [10, 10, 0, 0],
                padding: [0, 0, 0, 10],
                child: FadeIn(
//                  controller: _loadingController,
                  curve: Interval(.7, 1, curve: Curves.easeOut),
                  fadeDirection: FadeDirection.topToBottom,
                  offset: .5,
                  duration: 700.milliseconds,

                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: GFSegmentTabs(
                      tabController: tabController,
                      height: 60,
                      width: 280,
                      initialIndex: 1,
                      length: 3,
                      tabs: <Widget>[
                        FadeIn(
                          controller: _loadingController,
                          curve: headerAniInterval,
                          fadeDirection: FadeDirection.topToBottom,
                          offset: .5,
                          child: SizedBox.expand(
                            child: Tab(
                              child: buildButton(
                                size: 40,
                                icon: Icon(Icons.account_circle, size: 15),
                                label: 'Profile',
                                interval: Interval(0, aniInterval),
                                onPressed: () => tabController.animateTo(0),
                              ),
                            ),
                          ),
                        ),
                        FadeIn(
                          controller: _loadingController,
                          curve: headerAniInterval,
                          fadeDirection: FadeDirection.topToBottom,
                          offset: .5,
                          child: SizedBox.expand(
                            child: buildButton(
                              size: 40,
                              icon: Icon(Icons.ac_unit, size: 15),
                              label: 'Verification',
                              interval: Interval(0, aniInterval),
                              onPressed: () => tabController.animateTo(1),
                            ),
                          ),
                        ),
                        FadeIn(
                          controller: _loadingController,
                          curve: headerAniInterval,
                          fadeDirection: FadeDirection.topToBottom,
                          offset: .5,
                          child: SizedBox.expand(
                            child: buildButton(
                              size: 40,
                              icon: Icon(Icons.settings, size: 15),
                              label: 'Settings',
                              interval: Interval(0, aniInterval),
                              onPressed: () => tabController.animateTo(2),
                            ),
                          ),
                        ),
                      ],
                      tabBarColor: Colors.black87.withOpacity(0.4),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: GFColors.WHITE,
                      unselectedLabelColor: GFColors.DARK,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                        color: Colors.orange.withOpacity(0.3),
                      ),
                      indicatorPadding: const EdgeInsets.all(0),
                      indicatorWeight: 0,
                      border: Border.all(
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(0),
                        bottomLeft: Radius.circular(0),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(BuildContext context, FauiUser fauiUser) {
    const step = 0.04;
    const aniInterval = 0.75;
    parentHeight = context.heightPx;
    parentwidth = context.widthPx;

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: FadeIn(
              controller: _loadingController,
              curve: headerAniInterval,
              fadeDirection: FadeDirection.bottomToTop,
              offset: 1,
              child: CustomCard(
                elevation: 10,
                shadowColor: Colors.black,
                color: Color.fromRGBO(35, 47, 52, 0.8),
                borderRadius: [0, 0, 10, 10],
                padding: [0, 0, 0, 0],
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GFTabBarView(
                      controller: tabController,
                      children: <Widget>[
                        Center(
                          child: GridView.count(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
                            childAspectRatio: 5,
                            crossAxisSpacing: 25,
                            crossAxisCount: 2,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: TextField(controller: _firstCtrl, decoration: InputDecoration(labelText: "First Name")),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: TextField(controller: _lastCtrl, decoration: InputDecoration(labelText: "Last Name")),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: TextField(controller: _contactEmail, decoration: InputDecoration(labelText: "Gumroad Email")),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: GridView.count(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 25,
                            crossAxisCount: 3,
                            children: [
                              SlideFadeIn(
                                  begin: -130.0,
                                  end: 0,
                                  direction: "translateX",
                                  delay: (3 * 0.2) + 0.3,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: TextField(controller: _firstCtrl, decoration: InputDecoration(labelText: "First Name")),
                                  )),
                              SlideFadeIn(
                                  begin: -130.0,
                                  end: 0,
                                  direction: "translateX",
                                  delay: (6 * 0.2) + 0.3,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: TextField(controller: _lastCtrl, decoration: InputDecoration(labelText: "Last Name")),
                                  )),
                              SlideFadeIn(
                                  begin: -130.0,
                                  end: 0,
                                  direction: "translateX",
                                  delay: (9 * 0.2) + 0.3,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: TextField(controller: _serialNum, decoration: InputDecoration(labelText: "Activation Key (${data.getString("verified")})")),
                                  )),
                            ],
                          ),
                        ),
                        Center(
                          child: GridView.count(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 25,
                            crossAxisCount: 3,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: TextField(controller: _firstCtrl, decoration: InputDecoration(labelText: "First Name")),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: TextField(controller: _lastCtrl, decoration: InputDecoration(labelText: "Last Name")),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: TextField(controller: _serialNum, decoration: InputDecoration(labelText: "Activation Key")),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Flex(
            mainAxisAlignment: MainAxisAlignment.end,
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            children: [
              Spacer(flex: 95),
              Flex(direction: Axis.vertical, children: [
                Spacer(flex: (75)),
                FadeIn(
                  controller: _loadingController,
                  curve: headerAniInterval,
                  fadeDirection: FadeDirection.startToEnd,
                  offset: .5,
                  child: Container(
                    height: 48,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                      child: RaisedButton(child: Text("Save"), onPressed: _saveData),
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ]),
              Spacer(flex: 5)
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDebugButtons() {
    const textStyle = TextStyle(fontSize: 12, color: Colors.white);

    return Positioned(
      bottom: 0,
      right: 0,
      child: Row(
        children: <Widget>[
          RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.red,
            child: Text('loading', style: textStyle),
            onPressed: () => _loadingController.value == 0 ? _loadingController.forward().orCancel : _loadingController.reverse().orCancel,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () => _goToLogin(context, fauiUser),
      child: SafeArea(
        child: Scaffold(
            appBar: _buildAppBar(theme, fauiUser),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
              color: theme.primaryColor.withOpacity(.0),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        child: _getSettingsPage(context, fauiUser, theme),
                      ),
                      Expanded(
                        flex: 19,
                        child: _buildDashboardGrid(context, fauiUser),
                      ),
                      SizedBox(height: 0)
                    ],
                  ),
                  if (!kReleaseMode && _debug) _buildDebugButtons(),
                ],
              ),
            )),
      ),
    );
  }
}
