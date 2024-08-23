import 'dart:async';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nowser/provider/web_provider.dart';
import 'package:nowser/router/index/index_router.dart';
import 'package:nowser/router/web_tabs_select/web_tabs_select_router.dart';
import 'package:provider/provider.dart';
import 'package:receive_intent/receive_intent.dart' as receiveIntent;

import 'const/base.dart';
import 'const/router_path.dart';
import 'generated/l10n.dart';

late WebProvider webProvider;

late Map<String, WidgetBuilder> routes;

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  webProvider = WebProvider();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Locale? _locale;

    var lightTheme = getLightTheme();
    var darkTheme = getDarkTheme();
    ThemeData defaultTheme;
    ThemeData? defaultDarkTheme;
    defaultTheme = lightTheme;
    defaultDarkTheme = darkTheme;

    routes = {
      RouterPath.INDEX: (context) => IndexRouter(),
      RouterPath.WEB_TABS: (context) => WebTabsSelectRouter(),
    };

    return MultiProvider(
      providers: [
        ListenableProvider<WebProvider>.value(
          value: webProvider,
        ),
      ],
      child: MaterialApp(
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        // showPerformanceOverlay: true,
        debugShowCheckedModeBanner: false,
        locale: _locale,
        title: Base.APP_NAME,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        theme: defaultTheme,
        darkTheme: defaultDarkTheme,
        initialRoute: RouterPath.INDEX,
        routes: routes,
      ),
    );
  }
}

ThemeData getLightTheme() {
  return ThemeData(
    platform: TargetPlatform.iOS,
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
    platform: TargetPlatform.iOS,
  );
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   void _incrementCounter() {
//     // setState(() {
//     //   _counter++;
//     // });

//     index++;
//     index %= 3;
//     setState(() {});
//   }

//   StreamSubscription? _sub;

//   @override
//   void initState() {
//     super.initState();
//     _sub = receiveIntent.ReceiveIntent.receivedIntentStream.listen(
//         (receiveIntent.Intent? intent) {
//       log("receive intent!!!!!");
//       log(intent.toString());
//     }, onError: (err) {
//       print("listen error ");
//       print(err);
//     });
//     print("listen begin!");

//     test();
//   }

//   Future<void> test() async {
//     try {
//       final receivedIntent =
//           await receiveIntent.ReceiveIntent.getInitialIntent();
//       print(receivedIntent);
//       // Validate receivedIntent and warn the user, if it is not correct,
//       // but keep in mind it could be `null` or "empty"(`receivedIntent.isNull`).
//     } catch (e) {
//       // Handle exception
//     }
//   }

//   int index = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: IndexedStack(
//         index: index,
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(
//               url: WebUri(
//                 "https://xueqiu.com/",
//               ),
//             ),
//           ),
//           InAppWebView(
//             initialUrlRequest: URLRequest(
//               url: WebUri(
//                 "https://inappwebview.dev/",
//               ),
//             ),
//           ),
//           InAppWebView(
//             initialUrlRequest: URLRequest(
//               url: WebUri(
//                 "https://github.com/",
//               ),
//             ),
//           )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
