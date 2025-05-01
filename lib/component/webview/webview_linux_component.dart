// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:nostr_sdk/event.dart';
// import 'package:nostr_sdk/utils/string_util.dart';
// import 'package:nowser/component/webview/web_info.dart';
// import 'package:nowser/const/app_type.dart';
// import 'package:nowser/const/auth_type.dart';
// import 'package:nowser/main.dart';
// import 'package:nowser/provider/permission_check_mixin.dart';
// import 'package:webview_cef/webview_cef.dart';
// import 'package:webview_cef/src/webview_inject_user_script.dart';

// import '../../data/app.dart';

// class WebViewLinuxComponent extends StatefulWidget {
//   WebInfo webInfo;

//   Function(WebInfo, WebViewController) onWebViewCreated;

//   Function(WebInfo, WebViewController, String?) onTitleChanged;

//   Function(WebInfo, WebViewController, String?) onUrlChanged;

//   Function(WebInfo, WebViewController) onLoadStop;

//   WebViewLinuxComponent(
//     this.webInfo,
//     this.onWebViewCreated,
//     this.onTitleChanged,
//     this.onUrlChanged,
//     this.onLoadStop,
//   );

//   @override
//   State<StatefulWidget> createState() {
//     return _WebViewLinuxComponent();
//   }
// }

// class _WebViewLinuxComponent extends State<WebViewLinuxComponent>
//     with PermissionCheckMixin {
//   late WebViewController controller;

//   double progress = 0;

//   Set<JavascriptChannel> javascriptChannels = {};

//   InjectUserScripts injectScript = InjectUserScripts();

//   String url = "";

//   String title = "";

//   @override
//   void initState() {
//     super.initState();

//     initInjectScript();
//     initJSHandle();

//     controller = WebviewManager().createWebView(
//         loading: const Text("Loading"),
//         injectUserScripts: injectScript);
//     controller.setWebviewListener(WebviewEventsListener(
//       onTitleChanged: (title) {
//         title = title;
//         widget.onTitleChanged(widget.webInfo, controller, title);
//       },
//       onUrlChanged: (url) {
//         url = url;
//         widget.onUrlChanged(widget.webInfo, controller, url);
//       },
//       onConsoleMessage: (int level, String message, String source, int line) {
//         print("$level $source $line $message");
//       },
//       // onLoadStart: (controller, url) {
//       // },
//       onLoadEnd: (controller, url) {
//         widget.onLoadStop(widget.webInfo, controller);
//       },
//     ));

//     controller.initialize(widget.webInfo.url).then((v) {
//       controller.setJavaScriptChannels(javascriptChannels);
//       setState(() {
//         inited = true;
//       });

//       // controller.openDevTools();
//     });
//   }

//   var inited = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: inited ? controller.webviewWidget : controller.loadingWidget,
//     );
//   }

//   Future<void> nip07Reject(String resultId, String contnet) async {
//     var script = "window.nostr.reject(\"$resultId\", \"${contnet}\");";
//     await controller.executeJavaScript(script);
//   }

//   void initJSHandle() {
//     javascriptChannels.add(JavascriptChannel(name: "NowserJSgetPublicKey",
//       onMessageReceived: (javascriptMessage) async {
//       var jsMsg = javascriptMessage.message;
//         print("NowserJSgetPublicKey $jsMsg");
//         var jsonObj = jsonDecode(jsMsg);
//         var resultId = jsonObj["resultId"];

//         String? code = await getCode();
//         if (code == null) {
//           return;
//         }

//         checkPermission(context, AppType.WEB, code, AuthType.GET_PUBLIC_KEY,
//             (app) {
//           nip07Reject(resultId, "Forbid");
//         }, (app, signer) {
//           print("confirm get pubkey");
//           var pubkey = app.pubkey;
//           var script = "window.nostr.callback(\"$resultId\", \"$pubkey\");";
//           controller.executeJavaScript(script);
//         });
//       },)
//     );
//     javascriptChannels.add(JavascriptChannel(name: "NowserJSsignEvent",
//       onMessageReceived: (javascriptMessage) async {
//       var jsMsg = javascriptMessage.message;
//         print("NowserJSsignEvent $jsMsg");
//         var jsonObj = jsonDecode(jsMsg);
//         var resultId = jsonObj["resultId"];
//         var content = jsonObj["msg"];

//         String? code = await getCode();
//         if (code == null) {
//           return;
//         }

//         try {
//           var eventObj = jsonDecode(content);
//           var eventKind = eventObj["kind"];
//           if (eventKind is int) {
//             checkPermission(context, AppType.WEB, code, AuthType.SIGN_EVENT,
//                 eventKind: eventKind, authDetail: content, (app) {
//               nip07Reject(resultId, "Forbid");
//             }, (app, signer) async {
//               var tags = eventObj["tags"];
//               Event? event = Event(app.pubkey!, eventObj["kind"], tags ?? [],
//                   eventObj["content"],
//                   createdAt: eventObj["created_at"]);
//               event = await signer.signEvent(event);
//               if (event == null) {
//                 return;
//               }

//               var eventResultStr = jsonEncode(event.toJson());
//               // TODO this method to handle " may be error
//               eventResultStr = eventResultStr.replaceAll("\"", "\\\"");
//               var script =
//                   "window.nostr.callback(\"$resultId\", JSON.parse(\"$eventResultStr\"));";
//               controller.executeJavaScript(script);
//             });
//           }
//         } catch (e) {
//           nip07Reject(resultId, "Sign fail");
//         }
//       },)
//     );
//     javascriptChannels.add(JavascriptChannel(name: "NowserJSgetRelays",
//       onMessageReceived: (javascriptMessage) async {
//       var jsMsg = javascriptMessage.message;
//         print("NowserJSgetRelays $jsMsg");
//         var jsonObj = jsonDecode(jsMsg);
//         var resultId = jsonObj["resultId"];

//         String? code = await getCode();
//         if (code == null) {
//           return;
//         }

//         checkPermission(context, AppType.WEB, code, AuthType.GET_RELAYS, (app) {
//           nip07Reject(resultId, "Forbid");
//         }, (app, signer) {
//           // TODO handle getRelays
//           // var app = appProvider.getApp(AppType.WEB, code);
//           // if (app != null) {
//           //   var relayMaps = {};
//           //   var relayAddrs = relayProvider.relayAddrs;
//           //   for (var relayAddr in relayAddrs) {
//           //     relayMaps[relayAddr] = {"read": true, "write": true};
//           //   }
//           //   var resultStr = jsonEncode(relayMaps);
//           //   resultStr = resultStr.replaceAll("\"", "\\\"");
//           //   var script =
//           //       "window.nostr.callback(\"$resultId\", JSON.parse(\"$resultStr\"));";
//           //   webViewController!.evaluateJavascript(source: script);
//           // }
//         });
//       },)
//     );
//     javascriptChannels.add(JavascriptChannel(name: "NowserJSnip04encrypt",
//       onMessageReceived: (javascriptMessage) async {
//       var jsMsg = javascriptMessage.message;
//         print("NowserJSnip04encrypt $jsMsg");
//         var jsonObj = jsonDecode(jsMsg);
//         var resultId = jsonObj["resultId"];
//         var msg = jsonObj["msg"];
//         if (msg != null && msg is Map) {
//           var pubkey = msg["pubkey"];
//           var plaintext = msg["plaintext"];

//           String? code = await getCode();
//           if (code == null) {
//             return;
//           }

//           checkPermission(context, AppType.WEB, code, AuthType.NIP04_ENCRYPT,
//               (app) {
//             nip07Reject(resultId, "Forbid");
//           }, (app, signer) async {
//             var resultStr = await signer.encrypt(pubkey, plaintext);
//             if (StringUtil.isBlank(resultStr)) {
//               return;
//             }
//             var script =
//                 "window.nostr.callback(\"$resultId\", \"$resultStr\");";
//             controller.executeJavaScript(script);
//           });
//         }
//       },)
//     );
//     javascriptChannels.add(JavascriptChannel(name: "NowserJSnip04decrypt",
//       onMessageReceived: (javascriptMessage) async {
//       var jsMsg = javascriptMessage.message;
//         print("NowserJSnip04decrypt $jsMsg");
//         var jsonObj = jsonDecode(jsMsg);
//         var resultId = jsonObj["resultId"];
//         var msg = jsonObj["msg"];
//         if (msg != null && msg is Map) {
//           var pubkey = msg["pubkey"];
//           var ciphertext = msg["ciphertext"];

//           String? code = await getCode();
//           if (code == null) {
//             return;
//           }

//           checkPermission(context, AppType.WEB, code, AuthType.NIP04_DECRYPT,
//               (app) {
//             nip07Reject(resultId, "Forbid");
//           }, (app, signer) async {
//             var app = appProvider.getApp(AppType.WEB, code);
//             if (app != null) {
//               var resultStr = await signer.decrypt(pubkey, ciphertext);
//               if (StringUtil.isBlank(resultStr)) {
//                 return;
//               }
//               var script =
//                   "window.nostr.callback(\"$resultId\", \"$resultStr\");";
//               controller.executeJavaScript(script);
//             }
//           });
//         }
//       },)
//     );
//     javascriptChannels.add(JavascriptChannel(name: "NowserJSnip44encrypt",
//       onMessageReceived: (javascriptMessage) async {
//       var jsMsg = javascriptMessage.message;
//         print("NowserJSnip44encrypt $jsMsg");
//         var jsonObj = jsonDecode(jsMsg);
//         var resultId = jsonObj["resultId"];
//         var msg = jsonObj["msg"];
//         if (msg != null && msg is Map) {
//           var pubkey = msg["pubkey"];
//           var plaintext = msg["plaintext"];

//           String? code = await getCode();
//           if (code == null) {
//             return;
//           }

//           checkPermission(context, AppType.WEB, code, AuthType.NIP44_ENCRYPT,
//               (app) {
//             nip07Reject(resultId, "Forbid");
//           }, (app, signer) async {
//             var resultStr = await signer.nip44Encrypt(pubkey, plaintext);
//             if (StringUtil.isBlank(resultStr)) {
//               return;
//             }
//             var script =
//                 "window.nostr.callback(\"$resultId\", \"$resultStr\");";
//             controller.executeJavaScript(script);
//           });
//         }
//       },)
//     );
//     javascriptChannels.add(JavascriptChannel(name: "NowserJSnip44decrypt",
//       onMessageReceived: (javascriptMessage) async {
//       var jsMsg = javascriptMessage.message;
//         print("NowserJSnip44decrypt $jsMsg");
//         var jsonObj = jsonDecode(jsMsg);
//         var resultId = jsonObj["resultId"];
//         var msg = jsonObj["msg"];
//         if (msg != null && msg is Map) {
//           var pubkey = msg["pubkey"];
//           var ciphertext = msg["ciphertext"];

//           String? code = await getCode();
//           if (code == null) {
//             return;
//           }

//           checkPermission(context, AppType.WEB, code, AuthType.NIP44_DECRYPT,
//               (app) {
//             nip07Reject(resultId, "Forbid");
//           }, (app, signer) async {
//             var resultStr = await signer.nip44Decrypt(pubkey, ciphertext);
//             if (StringUtil.isBlank(resultStr)) {
//               return;
//             }
//             var script =
//                 "window.nostr.callback(\"$resultId\", \"$resultStr\");";
//             controller.executeJavaScript(script);
//           });
//         }
//       },)
//     );
//   }

//   void initInjectScript() {
//     injectScript.add(UserScript("""
// window.nostr = {
// _call(channel, message) {
//     return new Promise((resolve, reject) => {
//         var resultId = "callbackResult_" + Math.floor(Math.random() * 100000000);
//         var arg = {"resultId": resultId};
//         if (message) {
//             arg["msg"] = message;
//         }
//         // var argStr = JSON.stringify(arg);
//         // window.flutter_inappwebview
//         //               .callHandler(channel, argStr);
//         channel(arg);
//         window.nostr._requests[resultId] = {resolve, reject}
//     });
// },
// _requests: {},
// callback(resultId, message) {
//     window.nostr._requests[resultId].resolve(message);
// },
// reject(resultId, message) {
//     window.nostr._requests[resultId].reject(message);
// },
// async getPublicKey() {
//     return window.nostr._call(NowserJSgetPublicKey);
// },
// async signEvent(event) {
//     return window.nostr._call(NowserJSsignEvent, JSON.stringify(event));
// },
// async getRelays() {
//     return window.nostr._call(NowserJSgetRelays);
// },
// nip04: {
//   async encrypt(pubkey, plaintext) {
//     return window.nostr._call(NowserJSnip04encrypt, {"pubkey": pubkey, "plaintext": plaintext});
//   },
//   async decrypt(pubkey, ciphertext) {
//       return window.nostr._call(NowserJSnip04decrypt, {"pubkey": pubkey, "ciphertext": ciphertext});
//   },
// },
// nip44: {
//   async encrypt(pubkey, plaintext) {
//     return window.nostr._call(NowserJSnip44encrypt, {"pubkey": pubkey, "plaintext": plaintext});
//   },
//   async decrypt(pubkey, ciphertext) {
//       return window.nostr._call(NowserJSnip44decrypt, {"pubkey": pubkey, "ciphertext": ciphertext});
//   },
// },
// };
// """, ScriptInjectTime.LOAD_START));
// // injectScript.add(UserScript("console.log(window.nostr);", ScriptInjectTime.LOAD_END));
//   }

//   Future<String?> getCode() async {
//     if (StringUtil.isBlank(url)) {
//       url = widget.webInfo.url;
//     }

//     if (StringUtil.isNotBlank(url)) {
//       var uri = Uri.parse(url);
//       return uri.host;
//     }

//     return null;
//   }

//   @override
//   Future<App> getApp(int appType, String code) async {
//     String? name = title;
//     String? image;
//     // var favicons = await webViewController!.getFavicons();
//     // if (favicons.isNotEmpty) {
//     //   image = favicons.first.url.toString();
//     // }
//     return App(appType: appType, code: code, name: name, image: image);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     controller.dispose();
//   }

// }
