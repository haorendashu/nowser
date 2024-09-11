import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nostr_sdk/client_utils/keys.dart';
import 'package:nostr_sdk/event.dart';
import 'package:nostr_sdk/event_kind.dart';
import 'package:nostr_sdk/filter.dart';
import 'package:nostr_sdk/nip46/nostr_remote_request.dart';
import 'package:nostr_sdk/nip46/nostr_remote_response.dart';
import 'package:nostr_sdk/relay/relay.dart';
import 'package:nostr_sdk/relay/relay_isolate.dart';
import 'package:nostr_sdk/relay/relay_status.dart';
import 'package:nostr_sdk/signer/local_nostr_signer.dart';
import 'package:nostr_sdk/signer/nostr_signer.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/const/app_type.dart';
import 'package:nowser/const/auth_type.dart';
import 'package:nowser/data/app.dart';
import 'package:nowser/provider/permission_check_mixin.dart';

import '../component/auth_dialog/auth_app_connect_dialog.dart';
import '../data/remote_signing_info.dart';
import '../data/remote_signing_info_db.dart';
import '../main.dart';

class RemoteSigningProvider extends ChangeNotifier with PermissionCheckMixin {
  BuildContext? context;

  void updateContext(BuildContext _context) {
    context = _context;
  }

  // remoteSignerPubkey - Relay
  Map<String, List<Relay>> relayMap = {};

  // remoteSignerPubkey - RemoteSigningInfo
  Map<String, RemoteSigningInfo> remoteSigningInfoMap = {};

  // remoteSignerPubkey - App
  Map<String, App> appMap = {};

  Future<void> reload() async {
    relayMap = {};
    remoteSigningInfoMap = {};
    appMap = {};

    load();
  }

  Future<void> load() async {
    var remoteAppList = appProvider.remoteAppList();
    for (var remoteApp in remoteAppList) {
      await addRemoteApp(remoteApp);
    }
  }

  Future<void> addRemoteApp(App remoteApp) async {
    var remoteSigningInfo = await RemoteSigningInfoDB.getByAppId(remoteApp.id!);
    if (remoteSigningInfo != null &&
        StringUtil.isNotBlank(remoteSigningInfo.remoteSignerKey) &&
        StringUtil.isNotBlank(remoteSigningInfo.remotePubkey) &&
        StringUtil.isNotBlank(remoteSigningInfo.localPubkey) &&
        StringUtil.isNotBlank(remoteSigningInfo.relays)) {
      var relays = connectToRelay(remoteSigningInfo);

      var remoteSignerPubkey = getPublicKey(remoteSigningInfo.remoteSignerKey!);
      remoteSigningInfoMap[remoteSignerPubkey] = remoteSigningInfo;
      appMap[remoteSignerPubkey] = remoteApp;
      relayMap[remoteSignerPubkey] = relays;
    }
  }

  List<Relay> connectToRelay(RemoteSigningInfo remoteSigningInfo) {
    var remoteSignerPubkey = getPublicKey(remoteSigningInfo.remoteSignerKey!);
    var relayAddrs = remoteSigningInfo.relays!.split(",");

    List<Relay> relays = [];
    for (var relayAddr in relayAddrs) {
      // use pubkey relace with
      var relay = RelayIsolate(relayAddr, RelayStatus(remoteSignerPubkey));

      var filter = Filter(
          p: [remoteSigningInfo.remotePubkey!],
          since: DateTime.now().millisecondsSinceEpoch ~/ 1000);
      relay.pendingAuthedMessages
          .add(["REQ", StringUtil.rndNameStr(10), filter.toJson()]);
      relay.pendingMessages
          .add(["REQ", StringUtil.rndNameStr(10), filter.toJson()]);
      relay.onMessage = _onEvent;

      relay.connect();
      relays.add(relay);
    }

    return relays;
  }

  Future<void> onRequest(
    Relay relay,
    NostrRemoteRequest request,
    RemoteSigningInfo remoteSigningInfo,
    String localPubkey,
    App? app,
  ) async {
    NostrSigner signerSigner =
        LocalNostrSigner(remoteSigningInfo.remoteSignerKey!);
    var remoteSignerPubkey = getPublicKey(remoteSigningInfo.remoteSignerKey!);
    var appType = AppType.REMOTE;
    var code = remoteSignerPubkey;

    NostrRemoteResponse? response;
    if (request.method == "ping") {
      response = NostrRemoteResponse(request.id, "pong");

      sendResponse(
          relay, response, signerSigner, localPubkey, remoteSignerPubkey);
    } else if (request.method == "connect") {
      if (app != null) {
        response = NostrRemoteResponse(request.id, "ack");
      } else {
        if (request.params.length <= 1) {
          response = NostrRemoteResponse(request.id, "", error: "params error");
        } else {
          if (request.params[0] == remoteSigningInfo.remotePubkey &&
              request.params[1] == remoteSigningInfo.secret) {
            // check pass, init app
            var newApp = await getApp(appType, code);
            await AuthAppConnectDialog.show(context!, newApp);
            // reload from provider
            app = appProvider.getApp(appType, code);
            if (app == null) {
              response =
                  NostrRemoteResponse(request.id, "", error: "connect fail");
            } else {
              remoteSigningInfo.appId = app.id;
              remoteSigningInfo.localPubkey = localPubkey;
              remoteSigningInfo.updatedAt =
                  DateTime.now().millisecondsSinceEpoch ~/ 1000;

              RemoteSigningInfoDB.update(remoteSigningInfo);
              remoteSigningInfoMap[remoteSignerPubkey] = remoteSigningInfo;
              appMap[remoteSignerPubkey] = app;

              _penddingRemoteApps.removeWhere((rsi) {
                if (rsi.id == remoteSigningInfo.id) {
                  return true;
                }
                return false;
              });

              response = NostrRemoteResponse(request.id, "ack");
            }
          } else {
            response = NostrRemoteResponse(request.id, "",
                error: "connect check fail");
          }
        }
      }

      if (response != null) {
        sendResponse(
            relay, response, signerSigner, localPubkey, remoteSignerPubkey);
      }
    } else {
      if (remoteSigningInfo.localPubkey != localPubkey) {
        // Remote signing should connect first.
        response = NostrRemoteResponse(request.id, "",
            error: "Local pubkey not allow.");
        sendResponse(
            relay, response, signerSigner, localPubkey, remoteSignerPubkey);
        return;
      }
      if (app == null) {
        // Remote signing should connect first.
        response = NostrRemoteResponse(request.id, "",
            error: "Remote signing should connect first.");
        sendResponse(
            relay, response, signerSigner, localPubkey, remoteSignerPubkey);
        return;
      }

      int? eventKind;
      String? authDetail;
      int authType = AuthType.GET_PUBLIC_KEY;
      dynamic eventObj;

      if (request.method == "sign_event") {
        authType = AuthType.SIGN_EVENT;
        authDetail = request.params[0];

        eventObj = jsonDecode(authDetail);
        eventKind = eventObj["kind"];
      } else if (request.method == "get_relays") {
        authType = AuthType.GET_RELAYS;
      } else if (request.method == "get_public_key") {
        authType = AuthType.GET_PUBLIC_KEY;
      } else if (request.method == "nip04_encrypt") {
        authType = AuthType.NIP04_ENCRYPT;
        authDetail = request.params[1];
      } else if (request.method == "nip04_decrypt") {
        authType = AuthType.NIP04_DECRYPT;
        authDetail = request.params[1];
      } else if (request.method == "nip44_encrypt") {
        authType = AuthType.NIP44_ENCRYPT;
        authDetail = request.params[1];
      } else if (request.method == "nip44_decrypt") {
        authType = AuthType.NIP44_DECRYPT;
        authDetail = request.params[1];
      }

      checkPermission(context!, appType, code, authType,
          eventKind: eventKind, authDetail: authDetail, (app) {
        response = NostrRemoteResponse(request.id, "", error: "forbid");
        sendResponse(
            relay, response, signerSigner, localPubkey, remoteSignerPubkey);
      }, (app, signer) async {
        if (request.method == "sign_event") {
          var tags = eventObj["tags"];
          Event? event = Event(
              app.pubkey!, eventObj["kind"], tags ?? [], eventObj["content"],
              createdAt: eventObj["created_at"]);
          log(jsonEncode(event.toJson()));
          event = await signer.signEvent(event);
          if (event == null) {
            log("sign event fail");
            return;
          }

          response =
              NostrRemoteResponse(request.id, jsonEncode(event.toJson()));
        } else if (request.method == "get_relays") {
          // TODO
        } else if (request.method == "get_public_key") {
          var pubkey = await signer.getPublicKey();
          response = NostrRemoteResponse(request.id, pubkey!);
        } else if (request.method == "nip04_encrypt") {
          var text = await signer.encrypt(localPubkey, authDetail);
          response = NostrRemoteResponse(request.id, text!);
        } else if (request.method == "nip04_decrypt") {
          var text = await signer.decrypt(localPubkey, authDetail);
          response = NostrRemoteResponse(request.id, text!);
        } else if (request.method == "nip44_encrypt") {
          var text = await signer.nip44Encrypt(localPubkey, authDetail);
          response = NostrRemoteResponse(request.id, text!);
        } else if (request.method == "nip44_decrypt") {
          var text = await signer.nip44Decrypt(localPubkey, authDetail);
          response = NostrRemoteResponse(request.id, text!);
        }

        sendResponse(
            relay, response, signerSigner, localPubkey, remoteSignerPubkey);
      });
    }
  }

  Future<void> sendResponse(Relay relay, NostrRemoteResponse? response,
      NostrSigner signer, String localPubkey, String remoteSignerPubkey) async {
    if (response != null) {
      var result = await response.encrypt(signer, localPubkey);
      Event? event = Event(
          remoteSignerPubkey,
          EventKind.NOSTR_REMOTE_SIGNING,
          [
            ["p", localPubkey]
          ],
          result!);
      event = await signer.signEvent(event);

      var signerPubkey = await signer.getPublicKey();
      // print("response:");
      if (event != null) {
        // print(event.toJson());
        relay.send(["EVENT", event.toJson()]);
      }
    }
  }

  Future<void> _onEvent(Relay relay, List<dynamic> json) async {
    // print("request");
    // print(json);

    var remoteSignerPubkey = relay.relayStatus.addr;
    var remoteSigningInfo = remoteSigningInfoMap[remoteSignerPubkey];
    if (remoteSigningInfo == null) {
      print("remoteSigningInfo is null");
      return;
    }
    var nostrSigner = LocalNostrSigner(remoteSigningInfo.remoteSignerKey!);
    var signer = keyProvider.getSigner(remoteSigningInfo.remotePubkey!);
    if (signer == null) {
      return;
    }

    final messageType = json[0];
    if (messageType == 'EVENT') {
      try {
        final event = Event.fromJson(json[2]);

        // add some statistics
        relay.relayStatus.noteReceive();

        event.sources.add(relay.url);

        if (event.kind == EventKind.NOSTR_REMOTE_SIGNING) {
          var request = await NostrRemoteRequest.decrypt(
              event.content, signer, event.pubkey);
          if (request != null) {
            onRequest(relay, request, remoteSigningInfo, event.pubkey,
                appMap[remoteSignerPubkey]);
          }
        }
      } catch (err) {
        log(err.toString());
      }
    } else if (messageType == 'EOSE') {
    } else if (messageType == "NOTICE") {
    } else if (messageType == "AUTH") {
      // auth needed
      if (json.length < 2) {
        log("AUTH result not right.");
        return;
      }

      final challenge = json[1] as String;
      var tags = [
        ["relay", relay.url],
        ["challenge", challenge]
      ];
      Event? event =
          Event(remoteSignerPubkey, EventKind.AUTHENTICATION, tags, "");
      event = await nostrSigner.signEvent(event);
      if (event != null) {
        relay.send(["AUTH", event.toJson()], forceSend: true);

        relay.relayStatus.authed = true;

        if (relay.pendingAuthedMessages.isNotEmpty) {
          Future.delayed(const Duration(seconds: 1), () {
            for (var message in relay.pendingAuthedMessages) {
              relay.send(message);
            }
            relay.pendingAuthedMessages.clear();
          });
        }
      }
    }
  }

  List<RemoteSigningInfo> _penddingRemoteApps = [];

  List<RemoteSigningInfo> get penddingRemoteApps => _penddingRemoteApps;

  void saveRemoteSigningInfo(RemoteSigningInfo remoteSigningInfo) {
    RemoteSigningInfoDB.insert(remoteSigningInfo);
    reloadPenddingRemoteApps();
    notifyListeners();
  }

  Future<void> reloadPenddingRemoteApps() async {
    var list = await RemoteSigningInfoDB.penddingRemoteSigningInfo();
    _penddingRemoteApps = list;
    notifyListeners();

    connectPenddingRemoteApp();
  }

  void connectPenddingRemoteApp() {
    for (var remoteSigningInfo in _penddingRemoteApps) {
      if (StringUtil.isNotBlank(remoteSigningInfo.remoteSignerKey) &&
          StringUtil.isNotBlank(remoteSigningInfo.remotePubkey) &&
          StringUtil.isNotBlank(remoteSigningInfo.relays)) {
        var relays = connectToRelay(remoteSigningInfo);

        var remoteSignerPubkey =
            getPublicKey(remoteSigningInfo.remoteSignerKey!);
        remoteSigningInfoMap[remoteSignerPubkey] = remoteSigningInfo;
        relayMap[remoteSignerPubkey] = relays;
      }
    }
  }
}
