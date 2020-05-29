// Flutter Parallax Background Navigation Demo
// @author Kenneth Reilly <kenneth@innovationgroup.tech>
// Copyright 2019 The Innovation Group - MIT License

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../data/models/settings_data.dart';
import '../data/provider/settings_provider.dart';

import 'navigation-bus.dart';

class Background extends StatefulWidget {
  const Background({Key key, @required String assetName})
      : _assetName = assetName,
        super(key: key);

  @override
  BackgroundState createState() => new BackgroundState();

  final String _assetName;
}

class BackgroundState extends State<Background> {
  GlobalConfiguration config = GlobalConfiguration();
  List<SettingsData> settings;

  double get _aspectRatio {
    return 16 / 5;
  }

  @override
  void initState() {
    super.initState();
    Function listener = (ControllerAttachedEvent event) {
      setState(() {});
    };
    NavigationBus.registerControllerAttachedListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    settings = Provider.of<SettingsDataProvider>(context).settings;

    Animation animation = NavigationBus.animation;

    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          double offset = animation.value * 0.35;
          return OverflowBox(
            maxWidth: double.infinity,
            alignment: Alignment(offset, 0),
            child: AspectRatio(
              aspectRatio: _aspectRatio,
              child: (settings == null || !settings[0].useBG)
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            alignment: Alignment(0, -0.5),
                            image: AssetImage(widget._assetName),
                          )))
                  : FadeInImage.memoryNetwork(
                      placeholderCacheHeight: 1024,
                      placeholder: kTransparentImage,
                      image: '${config.getString("address")}/${settings[0].bgImage}',
                      fit: BoxFit.fitWidth,
                    ),
            ),
          );
        });
  }
}
