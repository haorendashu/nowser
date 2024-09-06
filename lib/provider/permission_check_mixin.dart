import 'package:flutter/material.dart';
import 'package:nostr_sdk/signer/nostr_signer.dart';
import 'package:nowser/component/auth_dialog/auth_app_connect_dialog.dart';
import 'package:nowser/component/auth_dialog/auth_dialog.dart';
import 'package:nowser/component/user/user_login_dialog.dart';
import 'package:nowser/const/auth_result.dart';
import 'package:nowser/data/auth_log.dart';
import 'package:nowser/data/auth_log_db.dart';
import 'package:nowser/main.dart';

import '../const/connect_type.dart';
import '../data/app.dart';

mixin PermissionCheckMixin {
  Future<void> checkPermission(BuildContext context, int appType, String code,
      int authType, Function(App?) reject, Function(App, NostrSigner) confirm,
      {int? eventKind, String? authDetail}) async {
    if (keyProvider.keys.isEmpty) {
      // should add a key first
      await UserLoginDialog.show(context);
      if (keyProvider.keys.isEmpty) {
        return;
      }
    }

    var app = appProvider.getApp(appType, code);
    if (app == null) {
      // app is null, app connect
      var newApp = await getApp(appType, code);
      await AuthAppConnectDialog.show(context, newApp);
      // reload from provider
      app = appProvider.getApp(appType, code);
    }

    if (app == null) {
      // not allow connect
      reject(null);
      return;
    }

    var signer = getSigner(app.pubkey!);
    if (signer == null) {
      saveAuthLog(app, authType, eventKind, authDetail, AuthResult.REJECT);
      reject(app);
      return;
    }

    if (app.connectType == ConnectType.FULLY_TRUST) {
      saveAuthLog(app, authType, eventKind, authDetail, AuthResult.OK);
      confirm(app, signer);
      return;
    } else if (app.connectType == ConnectType.REASONABLE) {
      var permissionCheckResult = appProvider
          .checkPermission(appType, code, authType, eventKind: eventKind);
      print("permissionCheckResult $permissionCheckResult");
      if (permissionCheckResult == AuthResult.OK) {
        saveAuthLog(app, authType, eventKind, authDetail, AuthResult.OK);
        confirm(app, signer);
        return;
      } else if (permissionCheckResult == AuthResult.REJECT) {
        saveAuthLog(app, authType, eventKind, authDetail, AuthResult.REJECT);
        reject(app);
        return;
      }

      var authResult = await AuthDialog.show(context, app, authType,
          eventKind: eventKind, authDetail: authDetail);
      if (authResult == AuthResult.OK) {
        saveAuthLog(app, authType, eventKind, authDetail, AuthResult.OK);
        confirm(app, signer);
        return;
      }
    }

    saveAuthLog(app, authType, eventKind, authDetail, AuthResult.REJECT);
    reject(app);
    return;
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

  NostrSigner? getSigner(String pubkey) {
    return keyProvider.getSigner(pubkey);
  }
}
