import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/webview/web_info.dart';
import 'package:nowser/component/webview/webview_component.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/const/router_path.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/web_provider.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../component/webview/web_home_component.dart';
import '../../component/webview/webview_number_component.dart';
import 'web_control_component.dart';

class IndexWebComponent extends StatefulWidget {
  WebInfo webInfo;

  IndexWebComponent(this.webInfo, {required GlobalKey key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _IndexWebComponent();
  }
}

class _IndexWebComponent extends State<IndexWebComponent> {
  static const double BOTTOM_BTN_PADDING = 10;

  @override
  void initState() {
    super.initState();
    // print("indexWebComp initState ${widget.webInfo.id}");
  }

  @override
  void dispose() {
    super.dispose();
    // print("indexWebComp dispose ${widget.webInfo.id}");
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var padding = mediaQuery.padding;
    var maxWidth = mediaQuery.size.width;
    var titleWidth = maxWidth / 2;

    var webInfo = widget.webInfo;

    if (StringUtil.isBlank(webInfo.url)) {
      return WebHomeComponent(webInfo);
    }

    var webComp = WebViewComponent(
        webInfo,
        (webInfo, controller) {
          webInfo.controller = controller;
          webProvider.updateWebInfo(webInfo);
        },
        onTitleChanged,
        (webInfo, controller) {
          webInfo.controller = controller;
          webProvider.onLoadStop(webInfo);
        });

    var main = webComp;

    return Container(
      padding: EdgeInsets.only(
        top: padding.top,
        bottom: padding.bottom,
      ),
      child: main,
    );
  }

  void onTitleChanged(
      WebInfo webInfo, InAppWebViewController controller, String? title) {
    webInfo.controller = controller;
    webInfo.title = title;
    webProvider.updateWebInfo(webInfo);
  }
}
