
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nowser/component/webview/webview_controller_interface.dart';

class WebviewController extends WebviewControllerInterface {

  InAppWebViewController controller;

  WebviewController(this.controller);

  @override
  Future<void> reload() async {
    await controller.reload();
  }

  @override
  Future<void> goBack() async {
    await controller.goBack();
  }

  @override
  Future<bool> canGoBack() async {
    return await controller.canGoBack();
  }

  @override
  Future<void> goForward() async {
    await controller.goForward();
  }

  @override
  Future<Uri?> getUrl() async {
    var webUrl = await controller.getUrl();
    try {
      if (webUrl != null) {
        return webUrl.uriValue;
      }
    } catch (e) {}
    return null;
  }

  @override
  Future<String?> getFavicon() async {
    var favicons = await controller.getFavicons();
    if (favicons.isNotEmpty) {
      return favicons.first.url.toString();
    }
    return null;
  }

  @override
  Future<void> loadUrl(String url) async {
    await controller.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }
  
  @override
  Future<String?> getTitle() async {
    return controller.getTitle();
  }

}