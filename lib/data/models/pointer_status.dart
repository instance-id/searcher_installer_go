import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class PointerStatus extends ChangeNotifier {
  bool _pointerEnterStatus = false;
  bool _pointerHoverStatus = false;
  bool _pointerExitStatus = false;
  PointerEnterEvent _enterEvent;
  PointerHoverEvent _hoverEvent;
  PointerExitEvent _exitEvent;

  get pointerEnterStatus => _pointerEnterStatus;
  get pointerHoverStatus => _pointerHoverStatus;
  get pointerExitStatus => _pointerExitStatus;

  get getEnterEvent => _enterEvent;
  get getHoverEvent => _hoverEvent;
  get getExitEvent => _exitEvent;

  setPointerEnterStatus(value, event) {
    _pointerEnterStatus = value;
    _enterEvent = event;
    if (value = false) {
      _pointerHoverStatus = false;
      _hoverEvent = event;
    }
    notifyListeners();
  }

  setPointerHoverStatus(value) {
    _pointerHoverStatus = value;
    notifyListeners();
  }

  setPointerEnterEvent(event) {
    _enterEvent = event;
    notifyListeners();
  }

  setPointerExitEvent(value, event) {
    _pointerExitStatus = value;
    _exitEvent = event;
    notifyListeners();
  }

  setPointerHoverEvent(event) {
    _hoverEvent = event;
    notifyListeners();
  }
}

//
//    String _dataUrl = "https://reqres.in/api/users?per_page=20";
//    String _jsonResonse = "";
//    bool _isFetching = false;
//
//    bool get isFetching => _isFetching;
//
//    Future<void> fetchData() async {
//      _isFetching = true;
//      notifyListeners();
//
//      var response = await http.get(_dataUrl);
//      if (response.statusCode == 200) {
//        _jsonResonse = response.body;
//      }
//
//      _isFetching = false;
//      notifyListeners();
//    }
//
//    String get getResponseText => _jsonResonse;
//
//    List<dynamic> getResponseJson() {
//      if (_jsonResonse.isNotEmpty) {
//        Map<String, dynamic> json = jsonDecode(_jsonResonse);
//        return json['data'];
//      }
//      return null;
//    }
//
//    @override
//    // ignore: unused_element
//    Widget build(BuildContext context) {
//      // TODO: implement build
//      return null;
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return null;
//  }
//}
