import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nostr_sdk/event.dart';
import 'package:nostr_sdk/utils/platform_util.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/download_task_dialog.dart';
import 'package:nowser/component/webview/long_press_dialog.dart';
import 'package:nowser/component/webview/web_info.dart';
import 'package:nowser/const/app_type.dart';
import 'package:nowser/const/auth_type.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/data/browser_history.dart';
import 'package:nowser/data/browser_history_db.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/permission_check_mixin.dart';

import '../../const/auth_result.dart';
import '../../data/app.dart';

class WebViewComponent extends StatefulWidget {
  WebInfo webInfo;

  Function(WebInfo, InAppWebViewController) onWebViewCreated;

  Function(WebInfo, InAppWebViewController, String?) onTitleChanged;

  Function(WebInfo, InAppWebViewController, WebUri? url) onLoadStart;

  Function(WebInfo, InAppWebViewController, WebUri? url) onLoadStop;

  WebViewComponent(
    this.webInfo,
    this.onWebViewCreated,
    this.onTitleChanged,
    this.onLoadStart,
    this.onLoadStop,
  );

  @override
  State<StatefulWidget> createState() {
    return _WebViewComponent();
  }
}

class _WebViewComponent extends State<WebViewComponent>
    with PermissionCheckMixin {
  static const List<InAppWebViewHitTestResultType> _longPressResultSupported = [
    InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.IMAGE_TYPE
  ];

  InAppWebViewController? webViewController;

  late ContextMenu contextMenu;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    userAgent: Base.USER_AGENT,
  );

  PullToRefreshController? pullToRefreshController;

  double progress = 0;

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
      menuItems: [
        // ContextMenuItem(
        //     id: 1,
        //     title: "Special",
        //     action: () async {
        //       print("Menu item Special clicked!");
        //       print(await webViewController?.getSelectedText());
        //       await webViewController?.clearFocus();
        //     })
      ],
      settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
      onCreateContextMenu: (hitTestResult) async {
        // print("onCreateContextMenu");
        // print(hitTestResult.type);
        // print(hitTestResult.extra);
        // print(_longPressResultSupported
        //     .contains(hitTestResult.type)); // true or false
        // print(hitTestResult.extra);
        // print(await webViewController?.getSelectedText());

        if (!_longPressResultSupported.contains(hitTestResult.type)) {
          var selectedText = await webViewController?.getSelectedText();
          // TODO try to decode selectedText
        }
      },
      onHideContextMenu: () {
        // print("onHideContextMenu");
      },
      onContextMenuActionItemClicked: (contextMenuItemClicked) async {
        // var id = contextMenuItemClicked.id;
        // print("onContextMenuActionItemClicked: " +
        //     id.toString() +
        //     " " +
        //     contextMenuItemClicked.title);
      },
    );

    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    settings.incognito = widget.webInfo.incognitoMode;

    return Container(
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.webInfo.url)),
        initialUserScripts: UnmodifiableListView<UserScript>([]),
        initialSettings: settings,
        contextMenu: contextMenu,
        pullToRefreshController: pullToRefreshController,
        onWebViewCreated: (controller) async {
          webViewController = controller;
          initJSHandle(controller);
          widget.onWebViewCreated(widget.webInfo, controller);
        },
        onTitleChanged: (controller, title) {
          widget.onTitleChanged(widget.webInfo, controller, title);
        },
        onLoadStart: (controller, url) async {
          widget.onLoadStart(widget.webInfo, controller, url);
        },
        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT);
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          // var uri = navigationAction.request.url!;
          // if (uri.scheme == "lightning" &&
          //     StringUtil.isNotBlank(uri.path)) {
          //   var result =
          //       await NIP07Dialog.show(context, NIP07Methods.lightning);
          //   if (result == true) {
          //     await LightningUtil.goToPay(context, uri.path);
          //   }
          //   return NavigationActionPolicy.CANCEL;
          // }

          // if (uri.scheme == "nostr+walletconnect") {
          //   webViewProvider.closeAndReturn(uri.toString());
          //   return NavigationActionPolicy.CANCEL;
          // }

          // if (![
          //   "http",
          //   "https",
          //   "file",
          //   "chrome",
          //   "data",
          //   "javascript",
          //   "about"
          // ].contains(uri.scheme)) {
          //   if (await canLaunchUrl(uri)) {
          //     // Launch the App
          //     await launchUrl(
          //       uri,
          //     );
          //     // and cancel the request
          //     return NavigationActionPolicy.CANCEL;
          //   }
          // }

          return NavigationActionPolicy.ALLOW;
        },
        onLoadStop: (controller, url) async {
          pullToRefreshController?.endRefreshing();
          addInitScript(controller);
          widget.onLoadStop(widget.webInfo, controller, url);
        },
        onReceivedError: (controller, request, error) {
          pullToRefreshController?.endRefreshing();
        },
        onUpdateVisitedHistory: (controller, url, isReload) {},
        onConsoleMessage: (controller, consoleMessage) {
          print(consoleMessage);
        },
        onLongPressHitTestResult: (controller, hitTestResult) async {
          if (_longPressResultSupported.contains(hitTestResult.type)) {
            var requestFocusNodeHrefResult =
                await controller.requestFocusNodeHref();
            if (requestFocusNodeHrefResult != null) {
              int infoType = LongPressDialog.TYPE_IMAGE;
              if (InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE.toValue() ==
                  hitTestResult.type!.toValue()) {
                infoType = LongPressDialog.TYPE_URL;
              }
              LongPressDialog.show(
                  context, infoType, requestFocusNodeHrefResult.toJson());
            }
          }
        },
        onDownloadStartRequest: (InAppWebViewController controller,
            DownloadStartRequest downloadStartRequest) {
          String downloadUrl = downloadStartRequest.url.toString();
          DownloadTaskDialog.show(context, downloadUrl);
        },
      ),
    );
  }

  Future<void> nip07Reject(String resultId, String contnet) async {
    var script = "window.nostr.reject(\"$resultId\", \"${contnet}\");";
    await webViewController!.evaluateJavascript(source: script);
  }

  void initJSHandle(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: "Nowser_JS_getPublicKey",
      callback: (jsMsgs) async {
        var jsMsg = jsMsgs[0];
        print("Nowser_JS_getPublicKey $jsMsg");
        var jsonObj = jsonDecode(jsMsg);
        var resultId = jsonObj["resultId"];

        String? code = await getCode();
        if (code == null) {
          return;
        }

        checkPermission(context, AppType.WEB, code, AuthType.GET_PUBLIC_KEY,
            (app, rejectType) {
          nip07Reject(resultId, "Forbid");
        }, (app, signer) {
          print("confirm get pubkey");
          var pubkey = app.pubkey;
          var script = "window.nostr.callback(\"$resultId\", \"$pubkey\");";
          controller.evaluateJavascript(source: script);
        });
      },
    );
    controller.addJavaScriptHandler(
      handlerName: "Nowser_JS_signEvent",
      callback: (jsMsgs) async {
        var jsMsg = jsMsgs[0];
        print("Nowser_JS_signEvent $jsMsg");
        var jsonObj = jsonDecode(jsMsg);
        var resultId = jsonObj["resultId"];
        var content = jsonObj["msg"];

        String? code = await getCode();
        if (code == null) {
          return;
        }

        try {
          var eventObj = jsonDecode(content);
          var eventKind = eventObj["kind"];
          if (eventKind is int) {
            checkPermission(context, AppType.WEB, code, AuthType.SIGN_EVENT,
                eventKind: eventKind, authDetail: content, (app, rejectType) {
              nip07Reject(resultId, "Forbid");
            }, (app, signer) async {
              var tags = eventObj["tags"];
              Event? event = Event(app.pubkey!, eventObj["kind"], tags ?? [],
                  eventObj["content"],
                  createdAt: eventObj["created_at"]);
              event = await signer.signEvent(event);
              if (event == null) {
                return;
              }

              var eventResultStr = jsonEncode(event.toJson());
              // TODO this method to handle " may be error
              eventResultStr = eventResultStr.replaceAll("\"", "\\\"");
              var script =
                  "window.nostr.callback(\"$resultId\", JSON.parse(\"$eventResultStr\"));";
              webViewController!.evaluateJavascript(source: script);
            });
          }
        } catch (e) {
          nip07Reject(resultId, "Sign fail");
        }
      },
    );
    controller.addJavaScriptHandler(
      handlerName: "Nowser_JS_getRelays",
      callback: (jsMsgs) async {
        var jsMsg = jsMsgs[0];
        print("Nowser_JS_getRelays $jsMsg");
        var jsonObj = jsonDecode(jsMsg);
        var resultId = jsonObj["resultId"];

        String? code = await getCode();
        if (code == null) {
          return;
        }

        checkPermission(context, AppType.WEB, code, AuthType.GET_RELAYS,
            (app, rejectType) {
          nip07Reject(resultId, "Forbid");
        }, (app, signer) {
          // TODO handle getRelays
          var app = appProvider.getApp(AppType.WEB, code);
          if (app != null) {
            var relayMaps = {};
            // var relayAddrs = relayProvider.relayAddrs;
            // for (var relayAddr in relayAddrs) {
            //   relayMaps[relayAddr] = {"read": true, "write": true};
            // }
            var resultStr = jsonEncode(relayMaps);
            resultStr = resultStr.replaceAll("\"", "\\\"");
            var script =
                "window.nostr.callback(\"$resultId\", JSON.parse(\"$resultStr\"));";
            webViewController!.evaluateJavascript(source: script);
          }
        });
      },
    );
    controller.addJavaScriptHandler(
      handlerName: "Nowser_JS_nip04_encrypt",
      callback: (jsMsgs) async {
        var jsMsg = jsMsgs[0];
        print("Nowser_JS_nip04_encrypt $jsMsg");
        var jsonObj = jsonDecode(jsMsg);
        var resultId = jsonObj["resultId"];
        var msg = jsonObj["msg"];
        if (msg != null && msg is Map) {
          var pubkey = msg["pubkey"];
          var plaintext = msg["plaintext"];

          String? code = await getCode();
          if (code == null) {
            return;
          }

          checkPermission(context, AppType.WEB, code, AuthType.NIP04_ENCRYPT,
              (app, rejectType) {
            nip07Reject(resultId, "Forbid");
          }, (app, signer) async {
            var resultStr = await signer.encrypt(pubkey, plaintext);
            if (StringUtil.isBlank(resultStr)) {
              return;
            }
            var script =
                "window.nostr.callback(\"$resultId\", \"$resultStr\");";
            webViewController!.evaluateJavascript(source: script);
          });
        }
      },
    );
    controller.addJavaScriptHandler(
      handlerName: "Nowser_JS_nip04_decrypt",
      callback: (jsMsgs) async {
        var jsMsg = jsMsgs[0];
        print("Nowser_JS_nip04_decrypt $jsMsg");
        var jsonObj = jsonDecode(jsMsg);
        var resultId = jsonObj["resultId"];
        var msg = jsonObj["msg"];
        if (msg != null && msg is Map) {
          var pubkey = msg["pubkey"];
          var ciphertext = msg["ciphertext"];

          String? code = await getCode();
          if (code == null) {
            return;
          }

          checkPermission(context, AppType.WEB, code, AuthType.NIP04_DECRYPT,
              (app, rejectType) {
            nip07Reject(resultId, "Forbid");
          }, (app, signer) async {
            var app = appProvider.getApp(AppType.WEB, code);
            if (app != null) {
              var resultStr = await signer.decrypt(pubkey, ciphertext);
              if (StringUtil.isBlank(resultStr)) {
                return;
              }
              var script =
                  "window.nostr.callback(\"$resultId\", \"$resultStr\");";
              webViewController!.evaluateJavascript(source: script);
            }
          });
        }
      },
    );
    controller.addJavaScriptHandler(
      handlerName: "Nowser_JS_nip44_encrypt",
      callback: (jsMsgs) async {
        var jsMsg = jsMsgs[0];
        print("Nowser_JS_nip44_encrypt $jsMsg");
        var jsonObj = jsonDecode(jsMsg);
        var resultId = jsonObj["resultId"];
        var msg = jsonObj["msg"];
        if (msg != null && msg is Map) {
          var pubkey = msg["pubkey"];
          var plaintext = msg["plaintext"];

          String? code = await getCode();
          if (code == null) {
            return;
          }

          checkPermission(context, AppType.WEB, code, AuthType.NIP44_ENCRYPT,
              (app, rejectType) {
            nip07Reject(resultId, "Forbid");
          }, (app, signer) async {
            var resultStr = await signer.nip44Encrypt(pubkey, plaintext);
            if (StringUtil.isBlank(resultStr)) {
              return;
            }
            var script =
                "window.nostr.callback(\"$resultId\", \"$resultStr\");";
            webViewController!.evaluateJavascript(source: script);
          });
        }
      },
    );
    controller.addJavaScriptHandler(
      handlerName: "Nowser_JS_nip44_decrypt",
      callback: (jsMsgs) async {
        var jsMsg = jsMsgs[0];
        print("Nowser_JS_nip44_decrypt $jsMsg");
        var jsonObj = jsonDecode(jsMsg);
        var resultId = jsonObj["resultId"];
        var msg = jsonObj["msg"];
        if (msg != null && msg is Map) {
          var pubkey = msg["pubkey"];
          var ciphertext = msg["ciphertext"];

          String? code = await getCode();
          if (code == null) {
            return;
          }

          checkPermission(context, AppType.WEB, code, AuthType.NIP44_DECRYPT,
              (app, rejectType) {
            nip07Reject(resultId, "Forbid");
          }, (app, signer) async {
            var resultStr = await signer.nip44Decrypt(pubkey, ciphertext);
            if (StringUtil.isBlank(resultStr)) {
              return;
            }
            var script =
                "window.nostr.callback(\"$resultId\", \"$resultStr\");";
            webViewController!.evaluateJavascript(source: script);
          });
        }
      },
    );
  }

  void addInitScript(InAppWebViewController controller) {
    controller.evaluateJavascript(source: """
window.nostr = {
_call(channel, message) {
    return new Promise((resolve, reject) => {
        var resultId = "callbackResult_" + Math.floor(Math.random() * 100000000);
        var arg = {"resultId": resultId};
        if (message) {
            arg["msg"] = message;
        }
        var argStr = JSON.stringify(arg);
        window.flutter_inappwebview
                      .callHandler(channel, argStr);
        window.nostr._requests[resultId] = {resolve, reject}
    });
},
_requests: {},
callback(resultId, message) {
    window.nostr._requests[resultId].resolve(message);
},
reject(resultId, message) {
    window.nostr._requests[resultId].reject(message);
},
async getPublicKey() {
    return window.nostr._call("Nowser_JS_getPublicKey");
},
async signEvent(event) {
    return window.nostr._call("Nowser_JS_signEvent", JSON.stringify(event));
},
async getRelays() {
    return window.nostr._call("Nowser_JS_getRelays");
},
nip04: {
  async encrypt(pubkey, plaintext) {
    return window.nostr._call("Nowser_JS_nip04_encrypt", {"pubkey": pubkey, "plaintext": plaintext});
  },
  async decrypt(pubkey, ciphertext) {
      return window.nostr._call("Nowser_JS_nip04_decrypt", {"pubkey": pubkey, "ciphertext": ciphertext});
  },
},
nip44: {
  async encrypt(pubkey, plaintext) {
    return window.nostr._call("Nowser_JS_nip44_encrypt", {"pubkey": pubkey, "plaintext": plaintext});
  },
  async decrypt(pubkey, ciphertext) {
      return window.nostr._call("Nowser_JS_nip44_decrypt", {"pubkey": pubkey, "ciphertext": ciphertext});
  },
},
};
""");
  }

  Future<String?> getCode() async {
    if (webViewController != null) {
      var url = await webViewController!.getUrl();
      if (url != null) {
        return url.host;
      }
    }

    return null;
  }

  @override
  Future<App> getApp(int appType, String code) async {
    String? name;
    String? image;
    if (webViewController != null) {
      name = await webViewController!.getTitle();

      var favicons = await webViewController!.getFavicons();
      if (favicons.isNotEmpty) {
        image = favicons.first.url.toString();
      }
    }
    return App(appType: appType, code: code, name: name, image: image);
  }
}
