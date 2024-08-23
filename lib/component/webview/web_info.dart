import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebInfo {
  String id;

  String url;

  WebInfo(this.id, this.url);

  InAppWebViewController? controller;

  String? title;

  WebInfo clone() {
    var wi = WebInfo(id, url);
    wi.controller = controller;
    wi.title = title;
    return wi;
  }
}
