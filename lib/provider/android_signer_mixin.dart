import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:nostr_sdk/event.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/const/app_type.dart';
import 'package:nowser/const/auth_result.dart';
import 'package:nowser/const/auth_type.dart';
import 'package:nowser/provider/permission_check_mixin.dart';
import 'package:receive_intent/receive_intent.dart' as receiveIntent;

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
    final intent = await receiveIntent.ReceiveIntent.getInitialIntent();
    if (intent != null) {
      log(intent.toString());
      log("from ${intent.fromPackageName}");
      log("action ${intent.action}");
      log("data ${intent.data}");
      log("categories ${intent.categories}");
      log("extra ${intent.extra}");

      if (StringUtil.isNotBlank(intent.data) &&
          intent.data!.startsWith(PREFIX)) {
        // This is an android signer intent
        var code = intent.fromPackageName;
        // Maybe it should check this signature
        // intent.fromSignatures;
        var extra = intent.extra;

        if (intent.extra != null) {
          var callId = extra!["id"];
          var authTypeStr = extra["type"];
          var currentUser = extra["current_user"];
          var pubkey = extra["pubKey"];
          pubkey ??= extra["pubkey"];

          if (StringUtil.isNotBlank(callId) &&
              StringUtil.isNotBlank(authTypeStr) &&
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
            }

            var playload = intent.data!.replaceFirst(PREFIX, "");
            int? eventKind;
            dynamic eventObj;
            if (authType == AuthType.SIGN_EVENT) {
              print(playload);
              eventObj = jsonDecode(playload);
              if (eventObj != null) {
                eventKind = eventObj["kind"];
                print("eventKind $eventKind");
              }
            }

            checkPermission(context, AppType.ANDROID_APP, code!, authType,
                eventKind: eventKind, authDetail: playload, (app) {
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
              print("checkPermission confrim $code");
              // confirm
              Map<String, Object?> data = {};
              data["id"] = callId;

              if (authType == AuthType.GET_PUBLIC_KEY) {
                // TODO should handle permissions
                // var permissions = extra["permissions"];
                var pubkey = await signer.getPublicKey();
                data["signature"] = Nip19.encodePubKey(pubkey!);
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
                data["event"] = jsonEncode(event.toJson());
                log("sig ${event.sig}");
              } else if (authType == AuthType.GET_RELAYS) {
                // TODO
              } else if (authType == AuthType.NIP04_ENCRYPT) {
                var result = await signer.encrypt(pubkey, playload);
                if (StringUtil.isNotBlank(result)) {
                  data["signature"] = result;
                }
              } else if (authType == AuthType.NIP04_DECRYPT) {
                var result = await signer.decrypt(pubkey, playload);
                if (StringUtil.isNotBlank(result)) {
                  data["signature"] = result;
                }
              } else if (authType == AuthType.NIP44_ENCRYPT) {
                var result = await signer.nip44Encrypt(pubkey, playload);
                if (StringUtil.isNotBlank(result)) {
                  data["signature"] = result;
                }
              } else if (authType == AuthType.NIP44_DECRYPT) {
                var result = await signer.nip44Decrypt(pubkey, playload);
                if (StringUtil.isNotBlank(result)) {
                  data["signature"] = result;
                }
              }

              saveAuthLog(app, authType, eventKind, playload, AuthResult.OK);

              print("setResult ok");
              print(data);

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
