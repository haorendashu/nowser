import 'package:flutter/material.dart';
import 'package:nowser/component/text_input/text_input_dialog.dart';
import 'package:nowser/component/user/user_name_component.dart';
import 'package:nowser/component/user/user_pic_component.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/const/router_path.dart';
import 'package:nowser/provider/app_provider.dart';
import 'package:nowser/provider/key_provider.dart';
import 'package:nowser/router/me/me_router_log_item_component.dart';
import 'package:nowser/router/me/me_router_web_item_component.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../keys/keys_router.dart';
import 'me_router_app_item_component.dart';

class MeRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeRouter();
  }
}

class _MeRouter extends State<MeRouter> {
  @override
  Widget build(BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);
    var themeData = Theme.of(context);
    var _appProvider = Provider.of<AppProvider>(context);

    var listWidgetMargin = const EdgeInsets.only(
      top: Base.BASE_PADDING,
      bottom: Base.BASE_PADDING,
    );

    List<Widget> defaultUserWidgets = [];
    defaultUserWidgets.add(Container(
      margin: const EdgeInsets.only(
        left: Base.BASE_PADDING,
      ),
      child: UserPicComponent(width: 50),
    ));
    defaultUserWidgets.add(Container(
      margin: const EdgeInsets.only(left: Base.BASE_PADDING),
      child: Selector<KeyProvider, List<String>>(
        builder: (context, npubList, child) {
          if (npubList.isNotEmpty) {
            var pubkey = npubList.first;
            return UserNameComponent(pubkey);
          }

          return GestureDetector(
            onTap: () {
              KeysRouter.addKey(context);
            },
            child: Text("Click and Login"),
          );
        },
        selector: (context, _provider) {
          return _provider.pubkeys;
        },
      ),
    ));
    defaultUserWidgets.add(Expanded(child: Container()));
    defaultUserWidgets.add(Container(
      margin: const EdgeInsets.only(right: Base.BASE_PADDING),
      child: const Icon(Icons.settings),
    ));
    var defaultUserWidget = Container(
      margin: const EdgeInsets.only(
        top: Base.BASE_PADDING,
      ),
      child: Row(
        children: defaultUserWidgets,
      ),
    );

    var memberListWidget = Selector<KeyProvider, List<String>>(
      builder: (context, npubList, child) {
        if (npubList.isEmpty) {
          return Container();
        }

        List<Widget> memberList = [];
        for (var pubkey in npubList) {
          memberList.add(Container(
            margin: EdgeInsets.only(left: Base.BASE_PADDING_HALF),
            child: UserPicComponent(width: 30),
          ));
        }
        memberList.add(Expanded(child: Container()));
        memberList.add(GestureDetector(
          child: Icon(Icons.chevron_right),
        ));

        return Container(
          decoration: BoxDecoration(
            color: themeData.cardColor,
            borderRadius: BorderRadius.circular(
              Base.BASE_PADDING,
            ),
          ),
          margin: listWidgetMargin,
          padding: EdgeInsets.all(Base.BASE_PADDING),
          child: GestureDetector(
            onTap: () {
              RouterUtil.router(context, RouterPath.KEYS);
            },
            behavior: HitTestBehavior.translucent,
            child: Row(
              children: memberList,
            ),
          ),
        );
      },
      selector: (context, _provider) {
        return _provider.pubkeys;
      },
    );

    List<Widget> webItemList = [];
    webItemList.add(MeRouterWebItemComponent(
      num: 102,
      name: "Bookmark",
      iconData: Icons.bookmark,
    ));
    webItemList.add(MeRouterWebItemComponent(
      num: 999,
      name: "History",
      iconData: Icons.history,
    ));
    webItemList.add(MeRouterWebItemComponent(
      num: 30,
      name: "Download",
      iconData: Icons.download,
    ));
    webItemList.add(MeRouterWebItemComponent(
      num: 102,
      name: "Bookmark",
      iconData: Icons.bookmark,
    ));
    var webItemWidget = Container(
      margin: listWidgetMargin,
      child: Row(
        children: webItemList,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );

    List<Widget> appWidgetList = [];
    var appList = _appProvider.appList;
    var length = appList.length;
    for (var i = 0; i < length && i < 3; i++) {
      var app = appList[i];
      appWidgetList.add(Container(
        child: MeRouterAppItemComponent(app),
      ));
      appWidgetList.add(Divider());
    }
    appWidgetList.add(Container(
      alignment: Alignment.center,
      child: Text(
        "Show more",
        style: TextStyle(
          decoration: TextDecoration.underline,
        ),
      ),
    ));
    var appListWidget = Container(
      margin: listWidgetMargin,
      padding: EdgeInsets.all(Base.BASE_PADDING),
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.circular(
          Base.BASE_PADDING,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: appWidgetList,
      ),
    );

    // TODO add zap send list here!

    List<Widget> logList = [];
    logList.add(Container(
      child: MeRouterLogItemComponent(),
    ));
    logList.add(Divider());
    logList.add(Container(
      child: MeRouterLogItemComponent(),
    ));
    logList.add(Divider());
    logList.add(Container(
      child: MeRouterLogItemComponent(),
    ));
    logList.add(Divider());
    logList.add(Container(
      alignment: Alignment.center,
      child: Text(
        "Show more",
        style: TextStyle(
          decoration: TextDecoration.underline,
        ),
      ),
    ));
    var logListWidget = Container(
      margin: listWidgetMargin,
      padding: EdgeInsets.all(Base.BASE_PADDING),
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.circular(
          Base.BASE_PADDING,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: logList,
      ),
    );

    var main = SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: Base.BASE_PADDING,
          right: Base.BASE_PADDING,
          top: mediaQueryData.padding.top + Base.BASE_PADDING,
          bottom: mediaQueryData.padding.bottom + Base.BASE_PADDING,
        ),
        child: Column(
          children: [
            defaultUserWidget,
            memberListWidget,
            webItemWidget,
            appListWidget,
            logListWidget,
          ],
        ),
      ),
    );

    return Scaffold(
      body: main,
    );
  }
}
