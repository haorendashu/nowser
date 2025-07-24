import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/platform_util.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/cust_state.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/const/base_consts.dart';
import 'package:nowser/main.dart';
import 'package:nowser/router/web_apps/web_app_item_component.dart';
import 'package:nowser/util/router_util.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../generated/l10n.dart';
import '../../util/dio_util.dart';
import 'web_app_item.dart';
import 'web_app_types.dart';

class WebAppsRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WebAppsRouterState();
  }
}

class WebAppsRouterState extends CustState<WebAppsRouter> {
  late S s;

  List<WebAppItem> items = [];

  Map<String, int> selectedMap = {};

  List<EnumObj> typeEnums = [];

  @override
  Widget doBuild(BuildContext context) {
    s = S.of(context);
    var themeData = Theme.of(context);

    if (typeEnums.isEmpty) {
      typeEnums.add(EnumObj(WebAppTypes.NOTES, s.Notes));
      typeEnums.add(EnumObj(WebAppTypes.LONG_FORM, s.Long_Form));
      typeEnums.add(EnumObj(WebAppTypes.GROUP_CHAT, s.Group_Chat));
      typeEnums.add(EnumObj(WebAppTypes.TOOLS, s.Tools));
      typeEnums.add(EnumObj(WebAppTypes.PHOTOS, s.Photos));
      typeEnums.add(EnumObj(WebAppTypes.STREAMING, s.Streaming));
      typeEnums.add(EnumObj(WebAppTypes.ZAPS, s.Zaps));
      typeEnums.add(EnumObj(WebAppTypes.Marketplaces, s.Marketplaces));
    }

    List<Widget> list = [];

    List<Widget> typeWidgetList = [];
    typeWidgetList
        .add(buildTypeWidget(EnumObj("all", s.All), selectedMap.isEmpty, () {
      if (selectedMap.isNotEmpty) {
        setState(() {
          selectedMap.clear();
        });
      }
    }));
    for (var typeEnum in typeEnums) {
      var selected = selectedMap[typeEnum.value] != null;
      typeWidgetList.add(buildTypeWidget(typeEnum, selected, () {
        if (selected) {
          setState(() {
            selectedMap.remove(typeEnum.value);
          });
        } else {
          setState(() {
            selectedMap[typeEnum.value] = 1;
          });
        }
      }));
    }
    list.add(Container(
      margin: const EdgeInsets.only(
        top: Base.BASE_PADDING,
        bottom: Base.BASE_PADDING,
      ),
      child: Wrap(
        children: typeWidgetList,
      ),
    ));

    List<WebAppItem> showItems = [];
    if (selectedMap.isNotEmpty) {
      for (var item in items) {
        for (var typeValue in item.types) {
          if (selectedMap[typeValue] != null) {
            showItems.add(item);
            break;
          }
        }
      }
    } else {
      showItems.addAll(items);
    }

    List<Widget> itemWidgetList = [];
    if (PlatformUtil.isPC()) {
      for (var i = 0; i < showItems.length; i += 2) {
        var item = showItems[i];
        if (i + 1 < showItems.length) {
          var item1 = showItems[i + 1];
          itemWidgetList.add(Container(
            child: Row(
              children: [
                Expanded(child: WebAppItemComponent(item, onTap: onTap)),
                Expanded(child: WebAppItemComponent(item1, onTap: onTap)),
              ],
            ),
          ));
        } else {
          itemWidgetList.add(Container(
            child: Row(
              children: [
                Expanded(child: WebAppItemComponent(item, onTap: onTap)),
                Expanded(child: Container()),
              ],
            ),
          ));
        }
      }
    } else {
      for (var item in showItems) {
        itemWidgetList.add(WebAppItemComponent(item));
      }
    }

    list.add(Expanded(
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: itemWidgetList,
          ),
        ),
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackBtnComponent(),
        title: Text(
          "Web APPs",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: themeData.textTheme.bodyLarge!.fontSize,
          ),
        ),
      ),
      body: Column(
        children: list,
      ),
    );
  }

  void onTap(WebAppItem item) {
    RouterUtil.back(context);
    webProvider.addTab(url: item.link);
  }

  @override
  Future<void> onReady(BuildContext context) async {
    load();
  }

  Future<void> load() async {
    var str = await DioUtil.getStr(Base.WEB_APPS);
    if (StringUtil.isNotBlank(str)) {
      var jsonList = jsonDecode(str!);
      if (jsonList is List) {
        items.clear();

        for (var jsonObj in jsonList) {
          var link = jsonObj["link"];
          var name = jsonObj["name"];
          var desc = jsonObj["desc"];
          var types = jsonObj["types"];
          var image = jsonObj["image"];

          // print(link);
          // print(name);
          // print(desc);
          // print(types);
          // print(types! is List);
          // print(image);

          if (StringUtil.isBlank(link) ||
              StringUtil.isBlank(name) ||
              StringUtil.isBlank(desc) ||
              types is! List) {
            continue;
          }

          items.add(WebAppItem(
              link, name, desc, types.map((item) => item.toString()).toList(),
              image: image));
        }
      }
    }

    setState(() {});
  }

  Widget buildTypeWidget(EnumObj enumObj, bool selected, Function onTap) {
    return Container(
      child: GestureDetector(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Checkbox(
                value: selected,
                onChanged: (_) {
                  onTap();
                },
              ),
            ),
            Container(
              child: Text(enumObj.name),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (items.isEmpty) {
      items.add(WebAppItem(
        "https://app.flotilla.social/",
        "Flotilla",
        "Relay chat client",
        [WebAppTypes.GROUP_CHAT],
        image: "https://nowser.nostrmo.com/images/apps/flotilla.png",
      ));
      items.add(WebAppItem(
        "https://www.zapplepay.com/",
        "Zapplepay",
        "Zap from any client 🖕",
        [WebAppTypes.TOOLS],
        image: "https://nowser.nostrmo.com/images/apps/zapplepay.png",
      ));
      items.add(WebAppItem(
        "https://habla.news/",
        "Habla",
        "A long form content client for nostr notes",
        [WebAppTypes.LONG_FORM],
        image: "https://nowser.nostrmo.com/images/apps/habla.png",
      ));
      items.add(WebAppItem(
        "https://listr.lol/",
        "Listr",
        "Create nostr lists",
        [WebAppTypes.TOOLS],
        image: "https://nowser.nostrmo.com/images/apps/listr.png",
      ));
      items.add(WebAppItem(
        "https://groups.nip29.com/",
        "Groups",
        "A relay-based NIP-29 group chat client",
        [WebAppTypes.GROUP_CHAT],
        image: "https://nowser.nostrmo.com/images/apps/groups.png",
      ));
      items.add(WebAppItem(
        "https://lumilumi.app/",
        "lumilumi",
        "Switch between full and low-data modes — a flexible Nostr web client",
        [WebAppTypes.NOTES],
        image: "https://nowser.nostrmo.com/images/apps/lumilumi.ico",
      ));
      items.add(WebAppItem(
        "https://iris.to/",
        "Iris",
        "Simple and fast web client",
        [WebAppTypes.NOTES],
        image: "https://nowser.nostrmo.com/images/apps/iris.png",
      ));

      // List<Map> jsonList = [];
      // for (var item in items) {
      //   jsonList.add(item.toJson());
      // }
      // log(jsonEncode(jsonList));

      setState(() {});
    }
  }
}
