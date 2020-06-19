import 'package:event/event.dart';
import 'package:logger/logger.dart';

import '../../data/provider/fb_auth_provider.dart';
import '../../services/service_locator.dart';

class ShowDashListener {
  final log = sl<Logger>();
  final event = Event();
  bool _showDash = false;

  bool get showDash => _showDash;

  void setStatus(bool value) {
    _showDash = value;
    event.broadcast();
    log.d('Show Dash? ${showDash}');
  }
}
