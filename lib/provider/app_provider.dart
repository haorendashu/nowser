import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/const/app_type.dart';
import 'package:nowser/const/auth_type.dart';
import 'package:nowser/const/connect_type.dart';
import 'package:nowser/data/app_db.dart';
import 'package:nowser/data/auth_log_db.dart';

import '../const/auth_result.dart';
import '../data/app.dart';
import '../data/remote_signing_info.dart';
import '../data/remote_signing_info_db.dart';

class AppProvider extends ChangeNotifier {
  List<App> _list = [];

  List<App> get appList => _list;

  List<App> remoteAppList() {
    List<App> apps = [];
    for (var app in _list) {
      if (app.appType == AppType.REMOTE) {
        apps.add(app);
      }
    }
    return apps;
  }

  Map<int, App> _appMap = {};

  Map<String, Map<String, int>> appPermissions = {};

  Future<void> reload() async {
    _appMap = {};
    appPermissions = {};
    var allApp = await AppDB.all();
    _list = allApp;
    for (var app in allApp) {
      _appMap[app.id!] = app;
    }
    notifyListeners();
  }

  Future<void> update(App app) async {
    app.updatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    AppDB.update(app);
    reload();
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
    _putPermissionMapValue(m, app.alwaysAllow, AuthResult.OK);
    _putPermissionMapValue(m, app.alwaysReject, AuthResult.REJECT);
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

  Future<void> deleteApp(App app) async {
    await AppDB.delete(app.id!);
    reload();

    try {
      await AuthLogDB.deleteByAppId(app.id!);
    } catch (e) {
      print(e.toString());
    }

    notifyListeners();
  }

  App? getAppById(int appId) {
    return _appMap[appId];
  }

  App? getApp(int appType, String code) {
    for (var app in _list) {
      if (app.appType == appType && app.code == code) {
        return app;
      }
    }

    return null;
  }

  void alwaysAllow(int appType, String code, int authType, int? eventKind) {
    _addAlways(appType, code, authType, eventKind, AuthResult.OK);
  }

  void alwaysReject(int appType, String code, int authType, int? eventKind) {
    _addAlways(appType, code, authType, eventKind, AuthResult.REJECT);
  }

  void _addAlways(
      int appType, String code, int authType, int? eventKind, int authResult) {
    var app = getApp(appType, code);
    if (app != null) {
      var permissionMap = _getPermissionMap(app);
      var key = "$authType";
      if (eventKind != null) {
        key = "$key-$eventKind";
      }
      permissionMap[key] = authResult;

      List<String> allowAuthTypeStrs = [];
      List<String> rejectAuthTypeStrs = [];

      List<String> allowEventKindStrs = [];
      List<String> rejectEventKindStrs = [];
      var entries = permissionMap.entries;
      for (var entry in entries) {
        var key = entry.key;
        var value = entry.value;

        if (key.contains("-")) {
          var strs = key.split("-");

          var eventKindStr = strs[1];
          if (value > 0) {
            allowEventKindStrs.add(eventKindStr);
          } else {
            rejectEventKindStrs.add(eventKindStr);
          }
        } else {
          var authTypeStr = key;
          if (value > 0) {
            allowAuthTypeStrs.add(authTypeStr);
          } else {
            rejectAuthTypeStrs.add(authTypeStr);
          }
        }
      }

      if (allowEventKindStrs.isNotEmpty) {
        allowAuthTypeStrs
            .add("${AuthType.SIGN_EVENT}-${allowEventKindStrs.join(",")}");
      }
      if (rejectEventKindStrs.isNotEmpty) {
        rejectAuthTypeStrs
            .add("${AuthType.SIGN_EVENT}-${rejectEventKindStrs.join(",")}");
      }

      app.alwaysAllow = allowAuthTypeStrs.join(";");
      app.alwaysReject = rejectAuthTypeStrs.join(";");

      var appCode = getAppCode(appType, code);
      appPermissions.remove(appCode);

      update(app);
    }
  }
}
