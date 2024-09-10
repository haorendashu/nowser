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
import 'package:nowser/const/auth_type.dart';
import 'package:nowser/data/app.dart';
import 'package:nowser/provider/permission_check_mixin.dart';

import '../data/remote_signing_info.dart';
import '../data/remote_signing_info_db.dart';
import '../main.dart';

class RemoteSigningProvider extends ChangeNotifier with PermissionCheckMixin {
  BuildContext? context;

  void updateContext(BuildContext _context) {
    context = _context;
  }

  // k - v ==> localPubkey - Relay
  Map<String, List<Relay>> relayMap = {};

  // localPubkey - RemoteSigningInfo
  Map<String, RemoteSigningInfo> remoteSigningInfoMap = {};

  // localPubkey - App
  Map<String, App> appMap = {};

  Future<void> reload() async {
    relayMap = {};
    remoteSigningInfoMap = {};
    appMap = {};
  }

  Future<void> load() async {
    var remoteAppList = appProvider.remoteAppList();
    for (var remoteApp in remoteAppList) {
      await add(remoteApp);
    }
  }

  Future<void> add(App remoteApp) async {
    var remoteSigningInfo = await RemoteSigningInfoDB.getByAppId(remoteApp.id!);
    if (remoteSigningInfo != null &&
        StringUtil.isNotBlank(remoteSigningInfo.remoteSignerKey) &&
        StringUtil.isNotBlank(remoteSigningInfo.localPubkey) &&
        StringUtil.isNotBlank(remoteSigningInfo.relays)) {
      var localPubkey = remoteSigningInfo.localPubkey!;
      var pubkey = getPublicKey(remoteSigningInfo.remoteSignerKey!);
      var relayAddrs = remoteSigningInfo.relays!.split(",");

      List<Relay> relays = [];
      for (var relayAddr in relayAddrs) {
        // use pubkey relace with
        var relay = RelayIsolate(relayAddr, RelayStatus(localPubkey));

        var filter = Filter(p: [pubkey]);
        relay.pendingAuthedMessages
            .add(["REQ", StringUtil.rndNameStr(10), filter.toJson()]);
        relay.onMessage = _onEvent;

        relay.connect();
        relays.add(relay);
      }

      relayMap[localPubkey] = relays;
      remoteSigningInfoMap[localPubkey] = remoteSigningInfo;
    }
  }

  Future<void> onRequest(
    Relay relay,
    NostrRemoteRequest request,
    RemoteSigningInfo remoteSigningInfo,
    App app,
  ) async {
    String localPubkey = remoteSigningInfo.localPubkey!;
    NostrSigner signer = LocalNostrSigner(remoteSigningInfo.remoteSignerKey!);
    var remoteSignerPubkey = await signer.getPublicKey();
    var appType = app.appType!;
    var code = app.code!;

    NostrRemoteResponse? response;
    if (request.method == "ping") {
      response = NostrRemoteResponse(request.id, "pong");

      sendResponse(relay, response, signer, localPubkey, remoteSignerPubkey!);
    } else {
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
        sendResponse(relay, response, signer, localPubkey, remoteSignerPubkey!);
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

        sendResponse(relay, response, signer, localPubkey, remoteSignerPubkey!);
      });
    }
  }

  Future<void> sendResponse(Relay relay, NostrRemoteResponse? response,
      NostrSigner signer, String localPubkey, String remoteSignerPubkey) async {
    if (response != null) {
      var result = await response.encrypt(signer, localPubkey);
      var event = Event(
          remoteSignerPubkey!,
          EventKind.NOSTR_REMOTE_SIGNING,
          [
            ["p", localPubkey]
          ],
          result!);

      relay.send(["event", event.toJson()]);
    }
  }

  Future<void> _onEvent(Relay relay, List<dynamic> json) async {
    var localPubkey = relay.relayStatus.addr;
    var remoteSigningInfo = remoteSigningInfoMap[localPubkey];
    if (remoteSigningInfo == null) {
      print("remoteSigningInfo is null");
      return;
    }
    var remotePubkey = getPublicKey(remoteSigningInfo.remoteSignerKey!);
    var nostrSigner = LocalNostrSigner(remoteSigningInfo.remoteSignerKey!);

    final messageType = json[0];
    if (messageType == 'EVENT') {
      try {
        final event = Event.fromJson(json[2]);

        // add some statistics
        relay.relayStatus.noteReceive();

        event.sources.add(relay.url);

        if (event.kind == EventKind.NOSTR_REMOTE_SIGNING) {
          var request = await NostrRemoteRequest.decrypt(
              event.content, nostrSigner, localPubkey);
          if (request != null) {}
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
      Event? event = Event(remotePubkey, EventKind.AUTHENTICATION, tags, "");
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

  /**
   * The below code is design for relay n - remoteSignerKey n
   */

  // Map<String, RelayStatus> relayStatusMap = {};

  // // relayAddr - Relay
  // Map<String, Relay> relayMap = {};

  // // remoteSignerPubkey - RemoteSigningInfo
  // Map<String, RemoteSigningInfo> remoteSigningInfoMap = {};

  // Map<String, List<String>> relayToRemoteSignerPubkeys = {};

  // Map<String, List<String>> remoteSignerPubkeyToRelays = {};

  // /// relay - remoteSignerKey > n - n
  // /// ==>
  // /// relay - remoteSignerKey > 1 - n
  // /// remoteSigner - relay > 1 - n
  // Future<void> load() async {
  //   var remoteAppList = appProvider.remoteAppList();
  //   for (var remoteApp in remoteAppList) {
  //     var remoteSigningInfo =
  //         await RemoteSigningInfoDB.getByAppId(remoteApp.id!);
  //     if (remoteSigningInfo != null &&
  //         StringUtil.isNotBlank(remoteSigningInfo.remoteSignerKey) &&
  //         StringUtil.isNotBlank(remoteSigningInfo.localPubkey) &&
  //         StringUtil.isNotBlank(remoteSigningInfo.relays)) {
  //       var pubkey = getPublicKey(remoteSigningInfo.secret!);
  //       var relays = remoteSigningInfo.relays!.split(",");

  //       remoteSignerPubkeyToRelays[pubkey] = relays;
  //       remoteSigningInfoMap[pubkey] = remoteSigningInfo;

  //       for (var relay in relays) {
  //         relay = RelayAddrUtil.handle(relay);

  //         var pubkeys = relayToRemoteSignerPubkeys[relay];
  //         if (pubkeys == null) {
  //           pubkeys = [];
  //           relayToRemoteSignerPubkeys[relay] = pubkeys;
  //         }

  //         if (!pubkeys.contains(pubkey)) {
  //           pubkeys.add(pubkey);
  //         }
  //       }
  //     }
  //   }

  //   // data handle complete, begin to init relays
  //   for (var entry in relayToRemoteSignerPubkeys.entries) {
  //     var relayAddr = entry.key;
  //     var pubkeys = entry.value;

  //     var relayStatus = RelayStatus(relayAddr);
  //     relayStatusMap[relayAddr] = relayStatus;

  //     var relay = RelayIsolate(relayAddr, relayStatus);
  //     relayMap[relayAddr] = relay;

  //     // var filter = Filter(
  //     //     p: pubkeys, since: DateTime.now().millisecondsSinceEpoch ~/ 1000);
  //   }
  // }
}
