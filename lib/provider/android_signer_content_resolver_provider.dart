import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:android_content_provider/android_content_provider.dart';
import 'package:nostr_sdk/event.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/signer/nostr_signer.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/const/app_type.dart';
import 'package:nowser/provider/permission_check_mixin.dart';

import '../const/auth_result.dart';
import '../const/auth_type.dart';
import '../data/app.dart';
import '../main.dart';

class AndroidSignerContentResolverProvider extends AndroidContentProvider
    with PermissionCheckMixin {
  AndroidSignerContentResolverProvider(super.authority);

  @override
  Future<int> delete(
      String uri, String? selection, List<String>? selectionArgs) async {
    return 0;
  }

  @override
  Future<String?> getType(String uri) async {
    return null;
  }

  @override
  Future<String?> insert(String uri, ContentValues? values) async {
    return null;
  }

  bool inited = false;

  @override
  Future<CursorData?> query(String uri, List<String>? projection,
      String? selection, List<String>? selectionArgs, String? sortOrder) async {
    if (!inited) {
      await doInit();
      inited = true;
    }

    var authTypeStr =
        uri.replaceAll("content://com.github.haorendashu.nowser.", "");
    String authDetail = "";
    String? pubkey;
    String? currentUser;
    if (projection != null && projection.isNotEmpty) {
      authDetail = projection.first;
      if (projection.length > 1) {
        pubkey = projection[1];
      }
      if (projection.length > 2) {
        currentUser = projection[2];
      }
    }

    var authType = AuthType.GET_PUBLIC_KEY;
    if (authTypeStr == "GET_PUBLIC_KEY") {
      authType = AuthType.GET_PUBLIC_KEY;
    } else if (authTypeStr == "SIGN_EVENT") {
      authType = AuthType.SIGN_EVENT;
    } else if (authTypeStr == "GET_RELAYS") {
      authType = AuthType.GET_RELAYS;
    } else if (authTypeStr == "NIP04_ENCRYPT") {
      authType = AuthType.NIP04_ENCRYPT;
    } else if (authTypeStr == "NIP04_DECRYPT") {
      authType = AuthType.NIP04_DECRYPT;
    } else if (authTypeStr == "NIP44_ENCRYPT") {
      authType = AuthType.NIP44_ENCRYPT;
    } else if (authTypeStr == "NIP44_DECRYPT") {
      authType = AuthType.NIP44_DECRYPT;
    }

    int appType = AppType.ANDROID_APP;
    String code = "com.github.haorendashu.nostrmo";

    int? eventKind;
    dynamic eventObj;
    if (authType == AuthType.SIGN_EVENT) {
      eventObj = jsonDecode(authDetail);
      if (eventObj != null) {
        eventKind = eventObj["kind"];
      }
    }

    App? app;
    NostrSigner? signer;
    var complete = Completer();

    rejectFunc(_app) {
      saveAuthLog(_app, authType, eventKind, authDetail, AuthResult.REJECT);
      complete.complete();
    }

    confirmFunc(_app, _signer) {
      app = _app;
      signer = _signer;
      complete.complete();
    }

    checkPermission(null, appType, code, authType, rejectFunc, confirmFunc,
        eventKind: eventKind, authDetail: authDetail);

    await complete.future;
    if (signer == null || app == null) {
      return null;
    }

    MatrixCursorData? data;

    if (authType == AuthType.GET_PUBLIC_KEY) {
      // TODO should handle permissions
      // var permissions = extra["permissions"];
      var pubkey = await signer!.getPublicKey();
      data =
          MatrixCursorData(columnNames: ["signature"], notificationUris: [uri]);
      data.addRow([Nip19.encodePubKey(pubkey!)]);
    } else if (authType == AuthType.SIGN_EVENT) {
      var tags = eventObj["tags"];
      Event? event = Event(
          app!.pubkey!, eventObj["kind"], tags ?? [], eventObj["content"],
          createdAt: eventObj["created_at"]);
      log(jsonEncode(event.toJson()));
      event = await signer!.signEvent(event);
      if (event == null) {
        log("sign event fail");
        return null;
      }
      log("sig ${event.sig}");
      data = MatrixCursorData(
          columnNames: ["signature", "event"], notificationUris: [uri]);
      data.addRow([event.sig, jsonEncode(event.toJson())]);
    } else if (authType == AuthType.GET_RELAYS) {
      // TODO
    } else if (authType == AuthType.NIP04_ENCRYPT) {
      var result = await signer!.encrypt(pubkey, authDetail);
      if (StringUtil.isNotBlank(result)) {
        data = MatrixCursorData(
            columnNames: ["signature"], notificationUris: [uri]);
        data.addRow([result]);
      }
    } else if (authType == AuthType.NIP04_DECRYPT) {
      var result = await signer!.decrypt(pubkey, authDetail);
      if (StringUtil.isNotBlank(result)) {
        data = MatrixCursorData(
            columnNames: ["signature"], notificationUris: [uri]);
        data.addRow([result]);
      }
    } else if (authType == AuthType.NIP44_ENCRYPT) {
      var result = await signer!.nip44Encrypt(pubkey, authDetail);
      if (StringUtil.isNotBlank(result)) {
        data = MatrixCursorData(
            columnNames: ["signature"], notificationUris: [uri]);
        data.addRow([result]);
      }
    } else if (authType == AuthType.NIP44_DECRYPT) {
      var result = await signer!.nip44Decrypt(pubkey, authDetail);
      if (StringUtil.isNotBlank(result)) {
        data = MatrixCursorData(
            columnNames: ["signature"], notificationUris: [uri]);
        data.addRow([result]);
      }
    }

    if (data != null) {
      saveAuthLog(app!, authType, eventKind, authDetail, AuthResult.OK);
    }

    return data;
  }

  @override
  Future<int> update(String uri, ContentValues? values, String? selection,
      List<String>? selectionArgs) async {
    return 0;
  }
}
