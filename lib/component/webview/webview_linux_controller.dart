

// import 'package:webview_cef/webview_cef.dart';

// import 'webview_controller_interface.dart';

// class WebviewLinuxController extends WebviewControllerInterface {

//   WebViewController controller;

//   WebviewLinuxController(this.controller);

//   @override
//   Future<void> reload() async {
//     await controller.reload();
//   }

//   @override
//   Future<void> goBack() async {
//     await controller.goBack();
//   }

//   @override
//   Future<bool> canGoBack() async {
//     return true;
//   }

//   @override
//   Future<void> goForward() async {
//     await controller.goForward();
//   }

//   @override
//   Future<Uri?> getUrl() async {
//     try {
//       if (url != null) {
//         return Uri.parse(url!);
//       }
//     } catch (e) {}
//     return null;
//   }

//   @override
//   Future<String?> getFavicon() async {
//     return null;
//   }

//   @override
//   Future<void> loadUrl(String url) async {
//     await controller.loadUrl(url);
//   }
  
//   @override
//   Future<String?> getTitle() async {
//     return title;
//   }

//   String? title;

//   String? url;

//   void setTitle(String title) {
//     title = title;
//   }

//   void setUrl(String url) {
//     url = url;
//   }

// }