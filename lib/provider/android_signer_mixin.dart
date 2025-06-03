import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:nostr_sdk/event.dart';
import 'package:nostr_sdk/nip04/nip04.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nostr_sdk/zap/private_zap.dart';
import 'package:nowser/const/app_type.dart';
import 'package:nowser/const/auth_result.dart';
import 'package:nowser/const/auth_type.dart';
import 'package:nowser/provider/permission_check_mixin.dart';
import 'package:receive_intent/receive_intent.dart' as receiveIntent;
import 'package:hex/hex.dart';

mixin AndroidSignerMixin on PermissionCheckMixin {
  // StreamSubscription? _sub;
  // void listenIntent() {
  //   print("listenIntent call");
  //   _sub = receiveIntent.ReceiveIntent.receivedIntentStream.listen(
  //       (receiveIntent.Intent? intent) {
  //     log("receive intent!!!!!");
  //     if (intent != null) {
  //       log(intent.toString());
  //       log("from ${intent.fromPackageName}");
  //       log("action ${intent.action}");
  //       log("data ${intent.data}");
  //       log("categories ${intent.categories}");
  //       log("extra ${intent.extra}");
  //     }
  //   }, onError: (err) {
  //     print("listen error ");
  //     print(err);
  //   });
  // }

  static const String PREFIX = "nostrsigner:";

  Future<void> handleInitialIntent(BuildContext context) async {
    var intent = await getInitialIntent();
    await dohandleInitialIntent(context, intent);
  }

  Future<receiveIntent.Intent?> getInitialIntent() async {
    var intent = await receiveIntent.ReceiveIntent.getInitialIntent();
    if (intent != null) {
      log(intent.toString());
      log("from ${intent.fromPackageName}");
      log("action ${intent.action}");
      log("data ${intent.data}");
      log("categories ${intent.categories}");
      log("extra ${intent.extra}");
    }
    return intent;
  }

  Future<void> dohandleInitialIntent(
      BuildContext context, receiveIntent.Intent? intent) async {
    if (intent != null) {
      if (StringUtil.isNotBlank(intent.data) &&
          intent.data!.startsWith(PREFIX)) {
        // This is an android signer intent
        var code = intent.fromPackageName;
        // Maybe it should check this signature
        // intent.fromSignatures;
        var extra = intent.extra;

        if (intent.extra != null) {
          var callId = extra![
              "id"]; // sometime client don't send this id, don't need to check blank, just pass it return.
          var authTypeStr = extra["type"];
          var currentUser = extra["current_user"];
          var pubkey = extra["pubKey"];
          pubkey ??= extra["pubkey"];

          if (StringUtil.isNotBlank(authTypeStr) &&
              StringUtil.isNotBlank(code)) {
            var authType = AuthType.GET_PUBLIC_KEY;
            if (authTypeStr == "get_public_key") {
              authType = AuthType.GET_PUBLIC_KEY;
            } else if (authTypeStr == "sign_event") {
              authType = AuthType.SIGN_EVENT;
            } else if (authTypeStr == "get_relays") {
              authType = AuthType.GET_RELAYS;
            } else if (authTypeStr == "nip04_encrypt") {
              authType = AuthType.NIP04_ENCRYPT;
            } else if (authTypeStr == "nip04_decrypt") {
              authType = AuthType.NIP04_DECRYPT;
            } else if (authTypeStr == "nip44_encrypt") {
              authType = AuthType.NIP44_ENCRYPT;
            } else if (authTypeStr == "nip44_decrypt") {
              authType = AuthType.NIP44_DECRYPT;
            } else if (authTypeStr == "decrypt_zap_event") {
              authType = AuthType.DECRYPT_ZAP_EVENT;
            }

            var playload = intent.data!.replaceFirst(PREFIX, "");
            int? eventKind;
            dynamic eventObj;
            if (authType == AuthType.SIGN_EVENT ||
                authType == AuthType.DECRYPT_ZAP_EVENT) {
              // print(playload);
              eventObj = jsonDecode(playload);
              if (eventObj != null && authType == AuthType.SIGN_EVENT) {
                eventKind = eventObj["kind"];
                // print("eventKind $eventKind");
              }
            }

            checkPermission(context, AppType.ANDROID_APP, code!, authType,
                eventKind: eventKind, authDetail: playload, (app, rejectType) {
              // this place should do some about reject
              if (app != null) {
                saveAuthLog(
                    app, authType, eventKind, playload, AuthResult.REJECT);
              }
              receiveIntent.ReceiveIntent.setResult(
                receiveIntent.kActivityResultCanceled,
                shouldFinish: true,
              );
            }, (app, signer) async {
              // print("checkPermission confrim $code");
              // confirm
              Map<String, Object?> data = {};
              data["id"] = callId;
              var signerPubkey = await signer.getPublicKey();

              if (authType == AuthType.GET_PUBLIC_KEY) {
                // TODO should handle permissions
                // var permissions = extra["permissions"];
                data["signature"] = Nip19.encodePubKey(signerPubkey!);
                data["result"] = Nip19.encodePubKey(signerPubkey!);
                data["package"] = "com.github.haorendashu.nowser";
              } else if (authType == AuthType.SIGN_EVENT) {
                var tags = eventObj["tags"];
                Event? event = Event(app.pubkey!, eventObj["kind"], tags ?? [],
                    eventObj["content"],
                    createdAt: eventObj["created_at"]);
                log(jsonEncode(event.toJson()));
                event = await signer.signEvent(event);
                if (event == null) {
                  log("sign event fail");
                  return;
                }
                data["signature"] = event.sig;
                data["result"] = event.sig;
                data["event"] = jsonEncode(event.toJson());
                log("sig ${event.sig}");
              } else if (authType == AuthType.GET_RELAYS) {
                // TODO
              } else if (authType == AuthType.NIP04_ENCRYPT) {
                var result = await signer.encrypt(pubkey, playload);
                if (StringUtil.isNotBlank(result)) {
                  data["signature"] = result;
                  data["result"] = result;
                }
              } else if (authType == AuthType.NIP04_DECRYPT) {
                var result = await signer.decrypt(pubkey, playload);
                if (StringUtil.isNotBlank(result)) {
                  data["signature"] = result;
                  data["result"] = result;
                }
              } else if (authType == AuthType.NIP44_ENCRYPT) {
                var result = await signer.nip44Encrypt(pubkey, playload);
                if (StringUtil.isNotBlank(result)) {
                  data["signature"] = result;
                  data["result"] = result;
                }
              } else if (authType == AuthType.NIP44_DECRYPT) {
                var result = await signer.nip44Decrypt(pubkey, playload);
                if (StringUtil.isNotBlank(result)) {
                  data["signature"] = result;
                  data["result"] = result;
                }
              } else if (authType == AuthType.DECRYPT_ZAP_EVENT) {
                var event = Event.fromJson(eventObj);
                var source = await PrivateZap.decryptZapEvent(signer, event);
                data["signature"] = source;
                data["result"] = source;
              }

              saveAuthLog(app, authType, eventKind, playload, AuthResult.OK);

              // print("setResult ok");
              // print(data);

              receiveIntent.ReceiveIntent.setResult(
                receiveIntent.kActivityResultOk,
                data: data,
                shouldFinish: true,
              );
            });
          }
        }
      }
    }
  }
}
