import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../routes/home.dart';
import '../../routes/choose_location.dart';

enum NavPages { ScheduledJobs, Home, JobStatus, ProviderList }

class NavigationProvider with ChangeNotifier {
  int currentNavigation = 1;

  Widget get getNavigation {
    if (currentNavigation == 1) {
      return ChooseLocation();
    } else if (currentNavigation == 2) {
      return Home();
    } else {
      return Home();
    }
  }

  void updateNavigation(int navigation) {
    currentNavigation = navigation;
    notifyListeners();
  }
}
