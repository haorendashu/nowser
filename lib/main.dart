import 'dart:async';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nostr_sdk/utils/platform_util.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/data/db.dart';
import 'package:nowser/provider/android_signer_mixin.dart';
import 'package:nowser/provider/app_provider.dart';
import 'package:nowser/provider/bookmark_provider.dart';
import 'package:nowser/provider/build_in_relay_provider.dart';
import 'package:nowser/provider/key_provider.dart';
import 'package:nowser/provider/permission_check_mixin.dart';
import 'package:nowser/provider/web_provider.dart';
import 'package:nowser/router/app_detail/app_detail_router.dart';
import 'package:nowser/router/apps/add_remote_app_router.dart';
import 'package:nowser/router/apps/apps_router.dart';
import 'package:nowser/router/auth_log/auth_logs_router.dart';
import 'package:nowser/router/bookmark/bookmark_router.dart';
import 'package:nowser/router/history/history_router.dart';
import 'package:nowser/router/index/index_router.dart';
import 'package:nowser/router/keys/keys_router.dart';
import 'package:nowser/router/me/me_router.dart';
import 'package:nowser/router/web_tabs_select/web_tabs_select_router.dart';
import 'package:nowser/router/web_url_input/web_url_input_router.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:receive_intent/receive_intent.dart' as receiveIntent;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

import 'const/base.dart';
import 'const/colors.dart';
import 'const/router_path.dart';
import 'generated/l10n.dart';
import 'provider/android_signer_content_resolver_provider.dart';
import 'provider/data_util.dart';
import 'provider/remote_signing_provider.dart';
import 'provider/setting_provider.dart';
import 'util/colors_util.dart';
import 'util/media_data_cache.dart';

late WebProvider webProvider;

late SettingProvider settingProvider;

late KeyProvider keyProvider;

late AppProvider appProvider;

late RemoteSigningProvider remoteSigningProvider;

late Map<String, WidgetBuilder> routes;

late RootIsolateToken rootIsolateToken;

late BuildInRelayProvider buildInRelayProvider;

const QuickActions quickActions = QuickActions();

BookmarkProvider bookmarkProvider = BookmarkProvider();

late MediaDataCache mediaDataCache;

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  rootIsolateToken = RootIsolateToken.instance!;

  if (!PlatformUtil.isWeb() && PlatformUtil.isPC()) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      size: Size(1280, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: Base.APP_NAME,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  if (PlatformUtil.isWindowsOrLinux()) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  } catch (e) {
    print(e);
  }

  await doInit();

  mediaDataCache = MediaDataCache();
  await bookmarkProvider.init();

  runApp(MyApp());
}

Future<void> doInit() async {
  keyProvider = KeyProvider();
  appProvider = AppProvider();
  buildInRelayProvider = BuildInRelayProvider();

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
      RouterPath.BOOKMARK: (context) => BookmarkRouter(),
      RouterPath.AUTH_LOGS: (context) => AuthLogsRouter(),
    };

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: lightTheme.scaffoldBackgroundColor,
    ));

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
        ListenableProvider<BuildInRelayProvider>.value(
          value: buildInRelayProvider,
        ),
        ListenableProvider<BookmarkProvider>.value(
          value: bookmarkProvider,
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

@pragma('vm:entry-point')
Future<void> nowserSignerProviderEntrypoint() async {
  // if we call content resolver this should init first, to receive request.
  // so, doInit() method move to query method.
  AndroidSignerContentResolverProvider(
      'com.github.haorendashu.nowser.SIGN_EVENT;com.github.haorendashu.nowser.NIP04_ENCRYPT;com.github.haorendashu.nowser.NIP04_DECRYPT;com.github.haorendashu.nowser.NIP44_ENCRYPT;com.github.haorendashu.nowser.NIP44_DECRYPT;com.github.haorendashu.nowser.GET_PUBLIC_KEY;com.github.haorendashu.nowser.DECRYPT_ZAP_EVENT');
}
