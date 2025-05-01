import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/webview/web_info.dart';
import 'package:nowser/component/webview/webview_component.dart';
import 'package:nowser/component/webview/webview_controller.dart';
import 'package:nowser/component/webview/webview_linux_component.dart';
import 'package:nowser/component/webview/webview_linux_controller.dart';
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

    Widget? webComp;
    if (!Platform.isLinux) {
      webComp = WebViewComponent(
          webInfo,
          (webInfo, controller) {
            webInfo.controller = WebviewController(controller);
            webProvider.updateWebInfo(webInfo);
          },
          onTitleChanged,
          (webInfo, controller, url) {
            _checkSecure(webInfo, url.toString());
          },
          (webInfo, controller, url) {
            _checkSecure(webInfo, url.toString());
            webInfo.controller = WebviewController(controller);
            webProvider.onLoadStop(webInfo);
          });
    } else {
      // webComp = WebViewLinuxComponent(webInfo, (webInfo, controller) {
      //   webInfo.controller = WebviewLinuxController(controller);
      //   webProvider.updateWebInfo(webInfo);
      // }, (webInfo, controller, title) {
      //   if (webInfo.controller is WebviewLinuxController &&
      //       StringUtil.isNotBlank(title)) {
      //     (webInfo.controller as WebviewLinuxController).setTitle(title!);
      //     webInfo.title = title;
      //     webProvider.updateWebInfo(webInfo);
      //   }
      // }, (webInfo, controller, url) {
      //   if (webInfo.controller is WebviewLinuxController &&
      //       StringUtil.isNotBlank(url)) {
      //     if (url!.startsWith("https")) {
      //       webInfo.isSecure = true;
      //     } else {
      //       webInfo.isSecure = false;
      //     }

      //     print("url change! $url");
      //     (webInfo.controller as WebviewLinuxController).setUrl(url!);
      //     webInfo.url = url;
      //   }
      // }, (webInfo, controller) async {
      //   webInfo.controller ??= WebviewLinuxController(controller);
      //   var title = await webInfo.controller!.getTitle();
      //   webInfo.title = title;
      //   webProvider.onLoadStop(webInfo);
      // });
    }

    return Container(
      padding: EdgeInsets.only(
        top: padding.top,
      ),
      child: webComp,
    );
  }

  void _checkSecure(WebInfo webInfo, String url) {
    if (url.startsWith("https")) {
      webInfo.isSecure = true;
    } else {
      webInfo.isSecure = false;
    }
  }

  void onTitleChanged(
      WebInfo webInfo, InAppWebViewController controller, String? title) {
    webInfo.controller = WebviewController(controller);
    webInfo.title = title;
    webProvider.updateWebInfo(webInfo);
  }
}
