import 'package:flutter/material.dart';

import '../../data/browser_history.dart';
import 'webview_controller_interface.dart';

class WebInfo {
  String id;

  String url;

  bool incognitoMode;

  bool isSecure;

  WebInfo(this.id, this.url,
      {this.incognitoMode = false, this.isSecure = false});

  WebviewControllerInterface? controller;

  String? title;

  BrowserHistory? browserHistory;

  WebInfo clone() {
    var wi = WebInfo(id, url);
    wi.controller = controller;
    wi.title = title;
    wi.browserHistory = browserHistory;
    return wi;
  }

  Color? getBackgroundColor() {
    if (incognitoMode) {
      return Colors.grey;
    } else {
      return null;
    }
  }
}
