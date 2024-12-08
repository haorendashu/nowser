import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/bookmark_edit_dialog.dart';
import 'package:nowser/data/bookmark_db.dart';
import 'package:nowser/util/router_util.dart';

import '../component/webview/web_home_component.dart';
import '../component/webview/web_info.dart';
import '../data/bookmark.dart';
import '../data/browser_history.dart';
import '../data/browser_history_db.dart';
import '../router/index/index_web_component.dart';

class WebProvider extends ChangeNotifier {
  int index = 0;

  List<WebInfo> webInfos = [];

  WebInfo? getWebInfo(int i) {
    if (webInfos.length <= i) {
      return null;
    }
    return webInfos[i];
  }

  WebNumInfo getWebNumInfo() {
    return WebNumInfo(index, webInfos.length);
  }

  void checkBlank() {
    if (webInfos.isEmpty) {
      webInfos.add(WebInfo(_rndId(), ""));
      // webInfos.add(WebInfo(_rndId(), "https://www.oschina.net/"));
      // webInfos.add(WebInfo(_rndId(), "https://github.com/"));
    }
  }

  String _rndId() {
    return StringUtil.rndNameStr(10);
  }

  void updateWebInfo(WebInfo webInfo) {
    for (var i = 0; i < webInfos.length; i++) {
      var owi = webInfos[i];
      if (owi.id == webInfo.id) {
        webInfos[i] = webInfo;
        break;
      }
    }

    notifyListeners();
  }

  WebInfo? currentWebInfo() {
    return getWebInfo(index);
  }

  void goHome(WebInfo webInfo) {
    webInfo.url = "";
    webInfo.title = null;
    webInfo.controller = null;
    webInfo.browserHistory = null;
    updateWebInfo(webInfo);
  }

  Future<void> goBack(WebInfo webInfo) async {
    if (webInfo.controller != null) {
      if (await webInfo.controller!.canGoBack()) {
        webInfo.controller!.goBack();
        updateWebInfo(webInfo);
      } else {
        goHome(webInfo);
      }
    }
  }

  void addTab({String url = ""}) {
    if (StringUtil.isNotBlank(url)) {
      var _currentWebInfo = currentWebInfo();
      if (_currentWebInfo != null && StringUtil.isBlank(_currentWebInfo.url)) {
        _currentWebInfo.url = url;
        notifyListeners();
        return;
      }
    }

    webInfos.add(WebInfo(_rndId(), url));
    index = webInfos.length - 1;
    notifyListeners();
  }

  void checkAndOpenUrl(String url) {
    if (!url.startsWith("http")) {
      return;
    }

    int targetIndex = -1;
    for (var i = 0; i < webInfos.length; i++) {
      var webInfo = webInfos[i];
      if (webInfo.url.contains(url)) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex > -1) {
      if (index != targetIndex) {
        index = targetIndex;
        notifyListeners();
      }
    } else {
      var _currentWebInfo = currentWebInfo();
      if (_currentWebInfo != null && _currentWebInfo.url == "") {
        _currentWebInfo.url = url;
        notifyListeners();
      } else {
        addTab(url: url);
      }
    }
  }

  void changeIndex(WebInfo webInfo) {
    for (var i = 0; i < webInfos.length; i++) {
      var owi = webInfos[i];
      if (owi.id == webInfo.id) {
        index = i;
        break;
      }
    }

    notifyListeners();
  }

  void closeTab(WebInfo webInfo) {
    int i = 0;
    for (; i < webInfos.length; i++) {
      var owi = webInfos[i];
      if (owi.id == webInfo.id) {
        break;
      }
    }

    if (i == index) {
      index = 0;
    } else if (i < index) {
      index--;
    }

    indexWebviews.remove(webInfo.id);
    webInfos.removeAt(i);
    checkBlank();
    notifyListeners();
  }

  Future<void> onLoadStop(WebInfo webInfo) async {
    if (webInfo.controller == null) {
      return;
    }

    try {
      var url = await webInfo.controller!.getUrl();
      if (url == null) {
        return;
      }

      var title = await webInfo.controller!.getTitle();
      var favicons = await webInfo.controller!.getFavicons();
      String? favicon;
      if (favicons.isNotEmpty) {
        favicon = favicons.first.url.toString();
      }
      var browserHistory = BrowserHistory(
        title: title,
        favicon: favicon,
        url: url.toString(),
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      if (webInfo.browserHistory != null &&
          webInfo.browserHistory!.url == url.toString()) {
        return;
      }

      webInfo.browserHistory = browserHistory;
      BrowserHistoryDB.insert(browserHistory);

      updateWebInfo(webInfo);
    } catch (e) {}
  }

  void back(BuildContext context) {
    var webInfo = currentWebInfo();
    if (webInfo != null && webInfo.controller != null) {
      webInfo.controller!.goBack();
    }
  }

  void forward(BuildContext context) {
    var webInfo = currentWebInfo();
    if (webInfo != null && webInfo.controller != null) {
      webInfo.controller!.goForward();
    }
  }

  void refresh(BuildContext context) {
    var webInfo = currentWebInfo();
    if (webInfo != null && webInfo.controller != null) {
      webInfo.controller!.reload();
    }
  }

  bool currentGoTo(String? url) {
    var webInfo = currentWebInfo();

    if (webInfo != null) {
      return goTo(webInfo, url);
    }

    return false;
  }

  bool goTo(WebInfo webInfo, String? url) {
    if (url != null && url.startsWith("http")) {
      webInfo.url = url;
      webInfo.title = null;
      if (webInfo.controller != null) {
        webInfo.controller!.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
        return true;
      } else {
        updateWebInfo(webInfo);
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  Map<String, IndexWebComponent> indexWebviews = {};

  List<Widget> getIndexWebviews(BuildContext context, Function showControl) {
    List<Widget> list = [];
    for (var webInfo in webInfos) {
      if (StringUtil.isBlank(webInfo.url)) {
        list.add(WebHomeComponent(webInfo));
      } else {
        var indexWebComp = indexWebviews[webInfo.id];
        if (indexWebComp == null) {
          indexWebComp =
              IndexWebComponent(webInfo, showControl, key: GlobalKey());
          indexWebviews[webInfo.id] = indexWebComp;
        }

        list.add(indexWebComp);
      }
    }
    return list;
  }
}

class WebNumInfo {
  final int index;

  final int length;

  WebNumInfo(this.index, this.length);

  @override
  bool operator ==(Object other) {
    if (other is WebNumInfo) {
      return other.index == index && other.length == length;
    }
    return false;
  }
}
