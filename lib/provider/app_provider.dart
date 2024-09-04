import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/const/connect_type.dart';
import 'package:nowser/data/app_db.dart';

import '../const/auth_result.dart';
import '../data/app.dart';

class AppProvider extends ChangeNotifier {
  List<App> _list = [];

  Map<String, Map<String, int>> appPermissions = {};

  Future<void> reload() async {
    appPermissions = {};
    var allApp = await AppDB.all();
    _list = allApp;
    notifyListeners();
  }

  Future<void> add(App app) async {
    if (await AppDB.insert(app) > 0) {
      _list.add(app);
      notifyListeners();
    }
  }

  String getAppCode(int appType, String code) {
    return "${appType}_$code";
  }

  int checkPermission(int appType, String code, int authType,
      {int? eventKind}) {
    var app = getApp(appType, code);
    if (app != null) {
      if (app.connectType == ConnectType.FULLY_TRUST) {
        return AuthResult.OK;
      } else if (app.connectType == ConnectType.ALWAY_REJECT) {
        return AuthResult.REJECT;
      } else {
        var appCode = getAppCode(appType, code);
        var permissionsMap = appPermissions[appCode];
        if (permissionsMap == null) {
          permissionsMap = _getPermissionMap(app);
          appPermissions[appCode] = permissionsMap;
        }

        var key = "$authType";
        if (eventKind != null) {
          key = "$key-$eventKind";
        }

        var value = permissionsMap[key];
        if (value != null) {
          return value;
        }
      }
    }

    return AuthResult.ASK;
  }

  Map<String, int> _getPermissionMap(App app) {
    Map<String, int> m = {};
    _putPermissionMapValue(m, app.alwaysAllow, 1);
    _putPermissionMapValue(m, app.alwaysReject, -1);
    return m;
  }

  void _putPermissionMapValue(
      Map<String, int> m, String? permissionText, int value) {
    if (StringUtil.isNotBlank(permissionText)) {
      var permissionStrs = permissionText!.split(";");
      for (var permissionStr in permissionStrs) {
        var strs = permissionStr.split("-");

        var kindStr = strs[0];
        if (strs.length == 1) {
          m[kindStr] = value;
        } else if (strs.length > 1) {
          var eventKindsStr = strs[1];
          var eventKindStrs = eventKindsStr.split(",");
          for (var eventKindStr in eventKindStrs) {
            var key = "$kindStr-$eventKindStr";
            m[key] = value;
          }
        }
      }
    }
  }

  App? getApp(int appType, String code) {
    for (var app in _list) {
      if (app.appType == appType && app.code == code) {
        return app;
      }
    }

    return null;
  }
}
