import 'package:flutter/material.dart';
import 'package:searcher_installer_go/helpers/file_selector.dart';

class ChooseLocation extends StatefulWidget {
  @override
  ChooseLocationState createState() {
    return ChooseLocationState();
  }
}

class ChooseLocationState extends State<ChooseLocation>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FileSelector(),
    );
  }
}
