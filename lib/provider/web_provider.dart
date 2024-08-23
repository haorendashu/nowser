import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';

import '../component/webview/web_info.dart';

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
