import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/data/bookmark_db.dart';

import '../component/webview/web_info.dart';
import '../data/bookmark.dart';
import '../data/browser_history.dart';
import '../data/browser_history_db.dart';

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
    }
  }

  String _rndId() {
    return StringUtil.rndNameStr(10);
  }

  void updateWebInfo(WebInfo webInfo) {
    for (var i = 0; i < webInfos.length; i++) {
      var owi = webInfos[i];
      if (owi.id == webInfo.id) {
        webInfos[i] = webInfo.clone();
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

  void addTab() {
    webInfos.add(WebInfo(_rndId(), ""));
    index = webInfos.length - 1;
    notifyListeners();
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

    if (i < index) {
      index--;
    }

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

      BrowserHistoryDB.insert(browserHistory);

      webInfo.browserHistory = browserHistory;
      updateWebInfo(webInfo);
    } catch (e) {}
  }

  void addBookmark(WebInfo webInfo) {
    if (webInfo.browserHistory == null) {
      return;
    }

    var bookmark = Bookmark();
    bookmark.title = webInfo.title;
    bookmark.url = webInfo.browserHistory!.url;
    bookmark.favicon = webInfo.browserHistory!.favicon;
    bookmark.weight = 0;
    bookmark.addedToIndex = -1;
    bookmark.createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    BookmarkDB.insert(bookmark);
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
