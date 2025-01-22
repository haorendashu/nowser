import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/text_input/text_input_dialog.dart';
import 'package:nowser/const/router_path.dart';

import '../../component/enum_selector_component.dart';
import '../../const/base.dart';
import '../../const/base_consts.dart';
import '../../const/theme_style.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../util/locale_util.dart';
import '../../util/router_util.dart';
import 'setting_item_component.dart';

class SettingRouter extends StatefulWidget {
  Function indexReload;

  SettingRouter({
    required this.indexReload,
  });

  @override
  State<StatefulWidget> createState() {
    return _SettingRouter();
  }
}

class _SettingRouter extends State<SettingRouter> {
  void resetTheme() {
    widget.indexReload();
  }

  var listWidgetMargin = const EdgeInsets.only(
    top: Base.BASE_PADDING,
    bottom: Base.BASE_PADDING_HALF,
  );

  late S s;

  @override
  Widget build(BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);
    var themeData = Theme.of(context);
    s = S.of(context);

    var moreWidget = Icon(Icons.chevron_right);

    initI18nList(s);
    initThemeStyleList(s);
    initSearchEngineList(s);

    Widget titleWidget = Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(
        top: Base.BASE_PADDING + 10,
        left: Base.BASE_PADDING,
      ),
      child: Text(
        s.Setting,
        style: TextStyle(
          fontSize: themeData.textTheme.bodyLarge!.fontSize! + 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    List<Widget> configList = [];
    configList.add(SettingItemComponent(
      s.Language,
      value: getI18nList(settingProvider.i18n, settingProvider.i18nCC).name,
      onTap: pickI18N,
    ));
    configList.add(SettingItemComponent(
      s.ThemeStyle,
      value: getThemeStyle(settingProvider.themeStyle).name,
      showTopBorder: true,
      onTap: pickThemeStyle,
    ));
    configList.add(SettingItemComponent(
      s.Search_Engine,
      showTopBorder: true,
      onTap: pickSearchEngine,
      child: getSearchEngineWidget(settingProvider.searchEngine),
    ));
    var configListWidget = genConfigListWidget(configList, themeData);

    Widget aboutTitleWidget = genTitle(s.About, themeData);
    List<Widget> aboutList = [];
    // aboutList.add(SettingItemComponent("FAQ", child: moreWidget));
    aboutList.add(SettingItemComponent(
      s.About_Me,
      // showTopBorder: true,
      onTap: () {
        RouterUtil.router(context, RouterPath.ABOUT_ME);
      },
      child: moreWidget,
    ));
    // aboutList.add(SettingItemComponent(
    //   s.Privacy,
    //   child: moreWidget,
    //   showTopBorder: true,
    // ));
    var aboutListWidget = genConfigListWidget(aboutList, themeData);

    var main = SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: Base.BASE_PADDING,
          right: Base.BASE_PADDING,
          top: mediaQueryData.padding.top,
          bottom: mediaQueryData.padding.bottom + Base.BASE_PADDING,
        ),
        child: Column(
          children: [
            titleWidget,
            configListWidget,
            aboutTitleWidget,
            aboutListWidget,
          ],
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: main,
          ),
          Positioned(
            top: mediaQueryData.padding.top + Base.BASE_PADDING,
            right: 20,
            child: GestureDetector(
              onTap: () {
                RouterUtil.back(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    // border: Border.all(),
                    borderRadius: BorderRadius.circular(4),
                    color: themeData.hintColor.withOpacity(0.2)),
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget genTitle(String title, ThemeData themeData) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(
        top: Base.BASE_PADDING,
        left: Base.BASE_PADDING,
      ),
      child: Text(
        s.About,
        style: TextStyle(
          fontSize: themeData.textTheme.bodyLarge!.fontSize!,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget genConfigListWidget(List<Widget> configList, ThemeData themeData) {
    return Container(
      margin: listWidgetMargin,
      padding: const EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
        top: 3,
        bottom: 3,
      ),
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.circular(
          Base.BASE_PADDING,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: configList,
      ),
    );
  }

  List<EnumObj>? i18nList;

  void initI18nList(S s) {
    if (i18nList == null) {
      i18nList = [];
      i18nList!.add(EnumObj("", s.auto));
      for (var item in S.delegate.supportedLocales) {
        var key = LocaleUtil.getLocaleKey(item);
        i18nList!.add(EnumObj(key, key));
      }
    }
  }

  EnumObj getI18nList(String? i18n, String? i18nCC) {
    var key = LocaleUtil.genLocaleKeyFromSring(i18n, i18nCC);
    for (var eo in i18nList!) {
      if (eo.value == key) {
        return eo;
      }
    }
    return EnumObj("", S.of(context).auto);
  }

  Future pickI18N() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, i18nList!);
    if (resultEnumObj != null) {
      if (resultEnumObj.value == "") {
        settingProvider.setI18n(null, null);
      } else {
        for (var item in S.delegate.supportedLocales) {
          var key = LocaleUtil.getLocaleKey(item);
          if (resultEnumObj.value == key) {
            settingProvider.setI18n(item.languageCode, item.countryCode);
          }
        }
      }
      resetTheme();
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          // TODO others setting enumObjList
          i18nList = null;
          themeStyleList = null;
        });
      });
    }
  }

  List<EnumObj>? themeStyleList;

  void initThemeStyleList(S s) {
    if (themeStyleList == null) {
      themeStyleList = [];
      themeStyleList?.add(EnumObj(ThemeStyle.AUTO, s.Follow_System));
      themeStyleList?.add(EnumObj(ThemeStyle.LIGHT, s.Light));
      themeStyleList?.add(EnumObj(ThemeStyle.DARK, s.Dark));
    }
  }

  Future<void> pickThemeStyle() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, themeStyleList!);
    if (resultEnumObj != null) {
      settingProvider.themeStyle = resultEnumObj.value;
      resetTheme();
    }
  }

  EnumObj getThemeStyle(int themeStyle) {
    for (var eo in themeStyleList!) {
      if (eo.value == themeStyle) {
        return eo;
      }
    }
    return themeStyleList![0];
  }

  List<EnumObj>? searchEngineList;

  void initSearchEngineList(S s) {
    if (searchEngineList == null) {
      searchEngineList = [];
      searchEngineList!
          .add(EnumObj("https://duckduckgo.com/?&q=", "DuckDuckGo"));
      searchEngineList!
          .add(EnumObj("https://www.google.com/search?q=", "Google"));
      searchEngineList!.add(EnumObj("https://www.bing.com/search?q=", "Bing"));
      searchEngineList!
          .add(EnumObj("https://www.baidu.com/s?ie=UTF-8&wd=", "Baidu"));
      searchEngineList!.add(EnumObj("", s.Custom));
    }
  }

  Future<void> pickSearchEngine() async {
    EnumObj? resultEnumObj =
        await EnumSelectorComponent.show(context, searchEngineList!);
    if (resultEnumObj != null) {
      if (StringUtil.isNotBlank(resultEnumObj.value)) {
        settingProvider.searchEngine = resultEnumObj.value;
        resetTheme();
        return;
      }

      // custom config search engine
      var value = await TextInputDialog.show(context, s.Input_search_url_des);
      if (StringUtil.isNotBlank(value)) {
        settingProvider.searchEngine = value;
        resetTheme();
      }
    }
  }

  Widget getSearchEngineWidget(String? value) {
    if (StringUtil.isNotBlank(value)) {
      return Container(
        width: 180,
        child: Text(
          value!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      return Text("DuckDuckGo");
    }
  }
}
