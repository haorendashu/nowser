import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nowser/component/webview/web_info.dart';

class WebViewComponent extends StatefulWidget {
  WebInfo webInfo;

  Function(WebInfo, InAppWebViewController) onWebViewCreated;

  Function(WebInfo, InAppWebViewController, String?) onTitleChanged;

  WebViewComponent(
    this.webInfo,
    this.onWebViewCreated,
    this.onTitleChanged,
  );

  @override
  State<StatefulWidget> createState() {
    return _WebViewComponent();
  }
}

class _WebViewComponent extends State<WebViewComponent> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.webInfo.url)),
        onWebViewCreated: (controller) async {
          webViewController = controller;
          // initJSHandle(controller);
          widget.onWebViewCreated(widget.webInfo, controller);
        },
        onTitleChanged: (controller, title) {
          widget.onTitleChanged(widget.webInfo, controller, title);
        },
      ),
    );
  }
}
