import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nostr_sdk/signer/nostr_signer.dart';
import 'package:nowser/component/auth_dialog/auth_app_connect_dialog.dart';
import 'package:nowser/component/auth_dialog/auth_dialog.dart';
import 'package:nowser/component/user/user_login_dialog.dart';
import 'package:nowser/const/auth_result.dart';
import 'package:nowser/const/reject_type.dart';
import 'package:nowser/data/auth_log.dart';
import 'package:nowser/data/auth_log_db.dart';
import 'package:nowser/main.dart';

import '../const/connect_type.dart';
import '../data/app.dart';

mixin PermissionCheckMixin {
  Future<void> checkPermission(
      BuildContext? context,
      int appType,
      String code,
      int authType,
      Function(App?, int rejectType) reject,
      Function(App, NostrSigner) confirm,
      {int? eventKind,
      String? authDetail}) async {
    if (keyProvider.keys.isEmpty) {
      // should add a key first
      if (context != null) {
        await UserLoginDialog.show(context);
      }
      if (keyProvider.keys.isEmpty) {
        return;
      }
    }

    var app = appProvider.getApp(appType, code);
    if (app == null) {
      if (context != null) {
        app = await connectToApp(appType, code, context);
      }
    }

    if (app == null) {
      // not allow connect
      reject(null, RejectType.OTHERS);
      return;
    }

    var signer = await getSigner(app.pubkey!);
    if (signer == null) {
      saveAuthLog(app, authType, eventKind, authDetail, AuthResult.REJECT);
      reject(app, RejectType.OTHERS);
      return;
    }

    if (app.connectType == ConnectType.FULLY_TRUST) {
      try {
        confirm(app, signer);
        saveAuthLog(app, authType, eventKind, authDetail, AuthResult.OK);
      } catch (e) {
        print("confirm error $e");
        reject(app, RejectType.OTHERS);
        saveAuthLog(app, authType, eventKind, authDetail, AuthResult.REJECT);
      }
      return;
    } else if (app.connectType == ConnectType.REASONABLE) {
      var permissionCheckResult = appProvider
          .checkPermission(appType, code, authType, eventKind: eventKind);
      // print("permissionCheckResult $permissionCheckResult");
      if (permissionCheckResult == AuthResult.OK) {
        try {
          confirm(app, signer);
          saveAuthLog(app, authType, eventKind, authDetail, AuthResult.OK);
        } catch (e) {
          print("confirm error $e");
          reject(app, RejectType.OTHERS);
          saveAuthLog(app, authType, eventKind, authDetail, AuthResult.REJECT);
        }
        return;
      } else if (permissionCheckResult == AuthResult.REJECT) {
        saveAuthLog(app, authType, eventKind, authDetail, AuthResult.REJECT);
        reject(app, RejectType.REJECT);
        return;
      }

      if (context != null) {
        var authResult = await AuthDialog.show(context, app, authType,
            eventKind: eventKind, authDetail: authDetail);
        if (authResult == AuthResult.OK) {
          try {
            confirm(app, signer);
            saveAuthLog(app, authType, eventKind, authDetail, AuthResult.OK);
          } catch (e) {
            print("confirm error $e");
            reject(app, RejectType.OTHERS);
            saveAuthLog(
                app, authType, eventKind, authDetail, AuthResult.REJECT);
          }
          return;
        } else if (authResult == AuthResult.REJECT) {
          // return reject here ?
        }
      }
    }

    saveAuthLog(app, authType, eventKind, authDetail, AuthResult.REJECT);
    reject(app, RejectType.OTHERS);
    return;
  }

  Map<String, Future<App?>> connectingAppFutureMap = {};

  Future<App?> connectToApp(int appType, String code, BuildContext context) {
    var key = "$appType-$code";
    var f = connectingAppFutureMap[key];
    if (f != null) {
      return f;
    }

    var complete = Completer<App?>();
    f = complete.future;
    connectingAppFutureMap[key] = f;

    getApp(appType, code).then((newApp) => {
          AuthAppConnectDialog.show(context, newApp).then((value) {
            var app = appProvider.getApp(appType, code);
            complete.complete(app);
            connectingAppFutureMap.remove(key);
          })
        });

    return f;
  }

  void saveAuthLog(App app, int authType, int? eventKind, String? authDetail,
      int authResult) {
    if (app.id != null) {
      var authLog = AuthLog(
        appId: app.id,
        authType: authType,
        eventKind: eventKind,
        content: authDetail,
        authResult: authResult,
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      AuthLogDB.insert(authLog);
    }
  }

  // this method should override
  Future<App> getApp(int appType, String code) async {
    // TODO name, image
    return App(appType: appType, code: code);
  }

  Future<NostrSigner?> getSigner(String pubkey) {
    return keyProvider.getSigner(pubkey);
  }
}
