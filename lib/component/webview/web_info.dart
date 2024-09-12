import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../data/browser_history.dart';

class WebInfo {
  String id;

  String url;

  WebInfo(this.id, this.url);

  InAppWebViewController? controller;

  String? title;

  BrowserHistory? browserHistory;

  WebInfo clone() {
    var wi = WebInfo(id, url);
    wi.controller = controller;
    wi.title = title;
    wi.browserHistory = browserHistory;
    return wi;
  }
}
