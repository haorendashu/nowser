
import '../../data/browser_history.dart';
import 'webview_controller_interface.dart';

class WebInfo {
  String id;

  String url;

  WebInfo(this.id, this.url);

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
}
