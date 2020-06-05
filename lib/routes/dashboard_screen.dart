import 'package:firedart/auth/user_gateway.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get_it/get_it.dart';
import 'package:getflutter/colors/gf_color.dart';
import 'package:getflutter/components/tabs/gf_segment_tabs.dart';
import 'package:getflutter/components/tabs/gf_tabbar_view.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sized_context/sized_context.dart';

import '../animations/anim_FadeInHZ.dart';
import '../animations/anim_FadeInVT.dart';
import '../data/enums/enums.dart';
import '../data/events/authstatus_event.dart';
import '../data/extension/extensions.dart';
import '../data/provider/fb_auth_provider.dart';
import '../helpers/custom_card.dart';
import '../helpers/custom_color.dart';
import '../routes/login_screen.dart';
import '../widgets/constants.dart';
import '../widgets/login/widgets.dart';
import '../widgets/transition_route_observer.dart';
import '../widgets/widgets/fade_in.dart';
import '../widgets/widgets/round_button.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

GetIt sl = GetIt.instance;

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin, TransitionRouteAware {
  final log = sl<Logger>();
  final auth = sl<AuthStatusListener>();
  final data = GlobalConfiguration();
  bool updateData;
  AuthStatus currentStatus;

  final routeObserver = TransitionRouteObserver<PageRoute>();
  static const headerAniInterval = const Interval(.1, .3, curve: Curves.easeOut);
  AnimationController _loadingController;
  TextEditingController _firstCtrl = TextEditingController();
  TextEditingController _lastCtrl = TextEditingController();
  TextEditingController _serialNum = TextEditingController();
  TextEditingController _contactEmail = TextEditingController();
  dynamic _doc;
  bool _debug = false;

  double parentHeight;
  double parentwidth;
  TabController tabController;
  bool isDisposed = false;
  User user;

  @override
  void initState() {
    updateData = data.getBool("updateData");
    _debug = data.getBool("debug");
    user = context.read<FBAuthProvider>().user;

    if (user != null) {
      _loadData();
    }

    if (!isDisposed) {
      tabController = TabController(length: 3, vsync: this);
      _loadingController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1250),
      );

      tabController.animateTo(1);
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (!isDisposed) {
      routeObserver.unsubscribe(this);
      tabController.dispose();
      _loadingController.dispose();
      isDisposed = true;
    }
    super.dispose();
  }

  // 'Welcome ${guard(() => user?.displayName, 'Guest')}, ',
  Future<bool> _signOut({BuildContext context, User user}) async {
    if (context.read<FBAuthProvider>().isLoggedIn) {
      context.read<FBAuthProvider>().signOut();

      if (data.getBool("debug")) log.d("Logging Out");
      _doc = null;
      return Navigator.of(context).pushReplacementNamed(LoginScreen.routeName).then((_) => false);
    }
  }

  Future<void> _loadData() async {
    if (updateData) {
      _doc = await context.read<FBAuthProvider>().document ?? {"first": "", "last": "", "serialNum": "", "contactEmail": user.email};

      _firstCtrl.text = user.fname = _doc["first"];
      _lastCtrl.text = user.lname = _doc["last"];
      _serialNum.text = user.serialNum = _doc["serialNum"];
      user.verified = _doc["verified"];

      // @formatter:off
      (_doc["contactEmail"] == null || _doc["contactEmail"] == "") ? _contactEmail.text = user.contactEmail = user.email : _contactEmail.text = user.contactEmail = _doc["contactEmail"];

      if (data.getBool("debug")) log.d('Data Loaded : Firebase;');
      data.updateValue("updateData", false);
      data.updateValue("verified", verificationCheck(user));
      if (mounted) {
        setState(() {});
      }
    } else {
      _firstCtrl.text = user.fname ?? "";
      _lastCtrl.text = user.lname ?? "";
      _serialNum.text = user.serialNum ?? "";
      _contactEmail.text = user.contactEmail ?? user.email;

      if (data.getBool("debug")) log.d('Data Loaded : Local;');
    }
  }

  Future<void> _saveData() async {
    var doc = {
      "first": user.fname = _firstCtrl.text,
      "last": user.lname = _lastCtrl.text,
      "serialNum": user.serialNum = _serialNum.text,
      "contactEmail": user.contactEmail = _contactEmail.text,
    };

    await context.read<FBAuthProvider>().updateDoc(doc);

    if (data.getBool("debug")) log.d('UserId: ${user.id}');
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didPushAfterTransition() => _loadingController.forward();

  String verificationCheck(User user) {
    bool v = user.verified;
    if (data.getBool("debug")) log.d('Verified? ${v}');
    return (v) ? "Verified" : "Not Verified";
  }

  Widget headerType(ThemeData theme) {
    final accentColor = AppColors.GOLD;
    var loginOk = data.getBool('loginOk');
    if (!loginOk)
      return HeroText(
        "${Constants.appName}",
        tag: Constants.titleTag,
        smallFontSize: 30,
        textAlign: TextAlign.center,
        viewState: ViewState.shrunk,
        style: theme.textTheme.headline2.copyWith(
          shadows: [Shadow(color: AppColors.BG_DARK, blurRadius: 3)],
          fontWeight: FontWeight.w400,
          color: accentColor,
          fontSize: 30,
        ),
      );
    if (loginOk)
      return Text(
        "${Constants.appName}",
        style: theme.textTheme.headline2.copyWith(
          shadows: [Shadow(color: AppColors.BG_DARK, blurRadius: 3)],
          fontWeight: FontWeight.w400,
          color: accentColor,
          fontSize: 30,
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

  Widget _getSettingsPage(BuildContext context, User user, ThemeData theme) {
    const aniInterval = 0.75;
    parentHeight = context.heightPx;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FadeInVertical(
              delay: 0.0,
              distance: -75,
              duration: 500,
              child: CustomCard(
                elevation: 5,
                shadowColor: Colors.black,
                color: Color.fromRGBO(35, 47, 52, 0.8),
                roundness: 10,
                borderRadius: [10, 10, 0, 0],
                padding: [0, 0, 0, 10],
                child: FadeInVertical(
                  delay: 0.0,
                  distance: -75,
                  duration: 500,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: GFSegmentTabs(
                      tabController: tabController,
                      height: 60,
                      width: 280,
                      initialIndex: 1,
                      length: 3,
                      tabs: <Widget>[
                        FadeInVertical(
                          delay: 2.2,
                          distance: -75,
                          duration: 500,
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
                        FadeInVertical(
                          delay: 2.4,
                          distance: -75,
                          duration: 500,
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
                        FadeInVertical(
                          delay: 2.6,
                          distance: -75,
                          duration: 500,
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

  Widget _buildDashboardGrid(BuildContext context, User user) {
    parentHeight = context.heightPx;
    parentwidth = context.widthPx;

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: FadeInVertical(
              delay: 0.6,
              distance: 75,
              duration: 500,
              child: CustomCard(
                elevation: 10,
                shadowColor: Colors.black,
                color: Color.fromRGBO(35, 47, 52, 0.8),
                borderRadius: [0, 0, 10, 10],
                padding: [0, 0, 0, 0],
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    GFTabBarView(
                      controller: tabController,
                      children: <Widget>[
                        Center(
                          child: GridView.count(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
                            childAspectRatio: 5,
                            crossAxisSpacing: 25,
                            crossAxisCount: 2,
                            children: <Widget>[
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
                            children: <Widget>[
                              FadeInHorizontal(
                                  delay: 0.2,
                                  distance: -75,
                                  duratin: 500,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: TextField(controller: _firstCtrl, decoration: InputDecoration(labelText: "First Name")),
                                  )),
                              FadeInHorizontal(
                                  delay: 0.4,
                                  distance: -75,
                                  duratin: 500,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: TextField(controller: _lastCtrl, decoration: InputDecoration(labelText: "Last Name")),
                                  )),
                              FadeInHorizontal(
                                  delay: 0.6,
                                  distance: -75,
                                  duratin: 500,
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
                            children: <Widget>[
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
            children: <Widget>[
              Spacer(flex: 95),
              Flex(direction: Axis.vertical, children: <Widget>[
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
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () => _signOut(context: context,user: user),
      child: SafeArea(
          child: Scaffold(
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
                SizedBox(height: 22),
                Container(
                  child: _getSettingsPage(context, user, theme),
                ),
                Expanded(
                  flex: 19,
                  child: _buildDashboardGrid(context, user),
                ),
                SizedBox(height: 0)
              ],
            ),
            if (!kReleaseMode && _debug) _buildDebugButtons(),
          ],
        ),
      ))),
    );
  }
}
