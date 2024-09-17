import 'dart:async';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/data/db.dart';
import 'package:nowser/provider/android_signer_mixin.dart';
import 'package:nowser/provider/app_provider.dart';
import 'package:nowser/provider/key_provider.dart';
import 'package:nowser/provider/permission_check_mixin.dart';
import 'package:nowser/provider/web_provider.dart';
import 'package:nowser/router/app_detail/app_detail_router.dart';
import 'package:nowser/router/apps/add_remote_app_router.dart';
import 'package:nowser/router/apps/apps_router.dart';
import 'package:nowser/router/history/history_router.dart';
import 'package:nowser/router/index/index_router.dart';
import 'package:nowser/router/keys/keys_router.dart';
import 'package:nowser/router/me/me_router.dart';
import 'package:nowser/router/web_tabs_select/web_tabs_select_router.dart';
import 'package:nowser/router/web_url_input/web_url_input_router.dart';
import 'package:provider/provider.dart';
import 'package:receive_intent/receive_intent.dart' as receiveIntent;

import 'const/base.dart';
import 'const/colors.dart';
import 'const/router_path.dart';
import 'generated/l10n.dart';
import 'provider/data_util.dart';
import 'provider/remote_signing_provider.dart';
import 'provider/setting_provider.dart';
import 'util/colors_util.dart';

late WebProvider webProvider;

late SettingProvider settingProvider;

late KeyProvider keyProvider;

late AppProvider appProvider;

late RemoteSigningProvider remoteSigningProvider;

late Map<String, WidgetBuilder> routes;

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  keyProvider = KeyProvider();
  appProvider = AppProvider();

  var dataUtilTask = DataUtil.getInstance();
  var keyTask = keyProvider.init();
  var dbTask = DB.getCurrentDatabase();
  var dataFutureResultList = await Future.wait([dataUtilTask, keyTask, dbTask]);

  var settingTask = SettingProvider.getInstance();
  var appTask = appProvider.reload();
  var futureResultList = await Future.wait([settingTask, appTask]);
  settingProvider = futureResultList[0] as SettingProvider;
  webProvider = WebProvider();
  remoteSigningProvider = RemoteSigningProvider();

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
  void initState() {
    super.initState();
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
      RouterPath.WEB_URL_INPUT: (context) => WebUrlInputRouter(),
      RouterPath.ME: (context) => MeRouter(),
      RouterPath.KEYS: (context) => KeysRouter(),
      RouterPath.APPS: (context) => AppsRouter(),
      RouterPath.ADD_REMOTE_APP: (context) => AddRemoteAppRouter(),
      RouterPath.APP_DETAIL: (context) => AppDetailRouter(),
      RouterPath.HISTORY: (context) => HistoryRouter(),
    };

    return MultiProvider(
      providers: [
        ListenableProvider<WebProvider>.value(
          value: webProvider,
        ),
        ListenableProvider<KeyProvider>.value(
          value: keyProvider,
        ),
        ListenableProvider<AppProvider>.value(
          value: appProvider,
        ),
        ListenableProvider<RemoteSigningProvider>.value(
          value: remoteSigningProvider,
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
  Color color500 = _getMainColor();
  MaterialColor themeColor = ColorList.getThemeColor(color500.value);

  Color mainTextColor = Colors.black;
  Color hintColor = Colors.grey;
  var scaffoldBackgroundColor = Colors.grey[100];
  Color cardColor = Colors.white;

  if (settingProvider.mainFontColor != null) {
    mainTextColor = Color(settingProvider.mainFontColor!);
  }
  if (settingProvider.hintFontColor != null) {
    hintColor = Color(settingProvider.hintFontColor!);
  }
  if (settingProvider.cardColor != null) {
    cardColor = Color(settingProvider.cardColor!);
  }

  double baseFontSize = settingProvider.fontSize;

  var textTheme = TextTheme(
    bodyLarge: TextStyle(fontSize: baseFontSize + 2, color: mainTextColor),
    bodyMedium: TextStyle(fontSize: baseFontSize, color: mainTextColor),
    bodySmall: TextStyle(fontSize: baseFontSize - 2, color: mainTextColor),
  );
  var titleTextStyle = TextStyle(
    color: mainTextColor,
  );

  if (settingProvider.fontFamily != null) {
    textTheme =
        GoogleFonts.getTextTheme(settingProvider.fontFamily!, textTheme);
    titleTextStyle = GoogleFonts.getFont(settingProvider.fontFamily!,
        textStyle: titleTextStyle);
  }

  return ThemeData(
    platform: TargetPlatform.iOS,
    primarySwatch: themeColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: themeColor[500]!,
      brightness: Brightness.light,
    ),
    // scaffoldBackgroundColor: Base.SCAFFOLD_BACKGROUND_COLOR,
    // scaffoldBackgroundColor: Colors.grey[100],
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    primaryColor: themeColor[500],
    appBarTheme: AppBarTheme(
      backgroundColor: cardColor,
      titleTextStyle: titleTextStyle,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: ColorsUtil.hexToColor("#DFE1EB"),
    cardColor: cardColor,
    // dividerColor: Colors.grey[200],
    // indicatorColor: ColorsUtil.hexToColor("#818181"),
    textTheme: textTheme,
    hintColor: hintColor,
    buttonTheme: ButtonThemeData(),
    shadowColor: Colors.black.withOpacity(0.2),
    tabBarTheme: TabBarTheme(
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerHeight: 0,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey[200],
    ),
    bottomSheetTheme: BottomSheetThemeData(modalBarrierColor: Colors.red),
  );
}

ThemeData getDarkTheme() {
  Color color500 = _getMainColor();
  MaterialColor themeColor = ColorList.getThemeColor(color500.value);

  Color? mainTextColor;
  // Color? topFontColor = Colors.white;
  Color? topFontColor = Colors.grey[200];
  Color hintColor = Colors.grey;
  var scaffoldBackgroundColor = Color.fromARGB(255, 40, 40, 40);
  Color cardColor = Colors.black;

  if (settingProvider.mainFontColor != null) {
    mainTextColor = Color(settingProvider.mainFontColor!);
  }
  if (settingProvider.hintFontColor != null) {
    hintColor = Color(settingProvider.hintFontColor!);
  }
  if (settingProvider.cardColor != null) {
    cardColor = Color(settingProvider.cardColor!);
  }

  double baseFontSize = settingProvider.fontSize;

  var textTheme = TextTheme(
    bodyLarge: TextStyle(fontSize: baseFontSize + 2, color: mainTextColor),
    bodyMedium: TextStyle(fontSize: baseFontSize, color: mainTextColor),
    bodySmall: TextStyle(fontSize: baseFontSize - 2, color: mainTextColor),
  );
  var titleTextStyle = TextStyle(
    color: topFontColor,
    // color: Colors.black,
  );

  if (settingProvider.fontFamily != null) {
    textTheme =
        GoogleFonts.getTextTheme(settingProvider.fontFamily!, textTheme);
    titleTextStyle = GoogleFonts.getFont(settingProvider.fontFamily!,
        textStyle: titleTextStyle);
  }

  if (StringUtil.isNotBlank(settingProvider.backgroundImage)) {
    scaffoldBackgroundColor = Colors.transparent;
    cardColor = cardColor.withOpacity(0.6);
  }

  return ThemeData(
    platform: TargetPlatform.iOS,
    primarySwatch: themeColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: themeColor[500]!,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    primaryColor: themeColor[500],
    appBarTheme: AppBarTheme(
      backgroundColor: cardColor,
      titleTextStyle: titleTextStyle,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: Colors.grey[200],
    cardColor: cardColor,
    textTheme: textTheme,
    hintColor: hintColor,
    shadowColor: Colors.white.withOpacity(0.3),
    tabBarTheme: TabBarTheme(
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerHeight: 0,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey[200],
    ),
  );
}

Color _getMainColor() {
  Color color500 = const Color(0xff519495);
  if (settingProvider.themeColor != null) {
    color500 = Color(settingProvider.themeColor!);
  }
  return color500;
}
