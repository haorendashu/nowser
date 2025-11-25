import 'dart:convert';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_sdk/event.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/const/app_type.dart';
import 'package:nowser/const/auth_type.dart';
import 'package:nowser/provider/permission_check_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

class AppLinksService with PermissionCheckMixin {
  static const UNKNOWN_CODE = "unknown";

  var appLinks = AppLinks();

  BuildContext? context;

  void updateContext(BuildContext _context) {
    context = _context;
  }

  void listen() {
    appLinks.uriLinkStream.listen(handleUri);
  }

  void handleUri(Uri uri) {
    var callbackUrl = uri.queryParameters["callbackUrl"];
    var type = uri.queryParameters["type"];
    // var compressionType = uri.queryParameters["compressionType"]; // ignore compressionType now
    // var returnType = uri.queryParameters["returnType"]; // ignore returnType now

    // intent call also will call this method, if there isn't a type param skip the next handle and it may be a intent call.
    if (StringUtil.isBlank(type) || !uri.isScheme('nostrsigner')) {
      return;
    }
    log("AppLinksService $uri");

    var appType = AppType.URI;
    callbackUrl ??= UNKNOWN_CODE;
    var code = callbackUrl;

    int? eventKind;
    String? authDetail;
    String? thirdPartyPubkey;
    int authType = AuthType.GET_PUBLIC_KEY;
    dynamic eventObj;

    if (type == "sign_event") {
      authType = AuthType.SIGN_EVENT;
      authDetail = uri.host;

      eventObj = jsonDecode(authDetail);
      eventKind = eventObj["kind"];
    } else if (type == "get_relays") {
      authType = AuthType.GET_RELAYS;
    } else if (type == "get_public_key") {
      authType = AuthType.GET_PUBLIC_KEY;
    } else if (type == "nip04_encrypt") {
      authType = AuthType.NIP04_ENCRYPT;
      thirdPartyPubkey = uri.queryParameters["pubkey"];
      authDetail = uri.host;
    } else if (type == "nip04_decrypt") {
      authType = AuthType.NIP04_DECRYPT;
      thirdPartyPubkey = uri.queryParameters["pubkey"];
      authDetail = uri.host;
    } else if (type == "nip44_encrypt") {
      authType = AuthType.NIP44_ENCRYPT;
      thirdPartyPubkey = uri.queryParameters["pubkey"];
      authDetail = uri.host;
    } else if (type == "nip44_decrypt") {
      authType = AuthType.NIP44_DECRYPT;
      thirdPartyPubkey = uri.queryParameters["pubkey"];
      authDetail = uri.host;
    }

    checkPermission(context!, appType, code, authType,
        eventKind: eventKind, authDetail: authDetail, (app, rejectType) {
      // TODO How to return a reject message to app ?
      return;
    }, (app, signer) async {
      String? response;

      if (type == "sign_event") {
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

        response = event.sig;
      } else if (type == "get_relays") {
        response = '{}';
      } else if (type == "get_public_key") {
        response = await signer.getPublicKey();
      } else if (type == "nip04_encrypt") {
        response = await signer.encrypt(thirdPartyPubkey, authDetail);
      } else if (type == "nip04_decrypt") {
        response = await signer.decrypt(thirdPartyPubkey, authDetail);
      } else if (type == "nip44_encrypt") {
        response = await signer.nip44Encrypt(thirdPartyPubkey, authDetail);
      } else if (type == "nip44_decrypt") {
        response = await signer.nip44Decrypt(thirdPartyPubkey, authDetail);
      }

      sendResponse(callbackUrl!, response);
    });
  }

  Future<void> sendResponse(String callbackUrl, String? response) async {
    if (StringUtil.isBlank(response)) {
      return;
    }

    if (callbackUrl == UNKNOWN_CODE) {
      Clipboard.setData(ClipboardData(text: response!));
      return;
    }

    var url = callbackUrl + response!;
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
