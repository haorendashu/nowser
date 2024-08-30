import 'package:flutter/material.dart';
import 'package:nowser/component/text_input/text_input_dialog.dart';
import 'package:nowser/component/user_pic_component.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/const/router_path.dart';
import 'package:nowser/router/me/me_router_log_item_component.dart';
import 'package:nowser/router/me/me_router_web_item_component.dart';
import 'package:nowser/util/router_util.dart';

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

    var listWidgetMargin = EdgeInsets.only(
      top: Base.BASE_PADDING,
      bottom: Base.BASE_PADDING,
    );

    List<Widget> defaultUserWidgets = [];
    defaultUserWidgets.add(Container(
      margin: EdgeInsets.only(
        left: Base.BASE_PADDING,
      ),
      child: UserPicComponent(width: 50),
    ));
    defaultUserWidgets.add(Container(
      margin: EdgeInsets.only(left: Base.BASE_PADDING),
      child: GestureDetector(
        onTap: () {
          KeysRouter.addKey(context);
        },
        child: Text("Click and Login"),
      ),
    ));
    defaultUserWidgets.add(Expanded(child: Container()));
    defaultUserWidgets.add(Container(
      margin: EdgeInsets.only(right: Base.BASE_PADDING),
      child: Icon(Icons.settings),
    ));
    var defaultUserWidget = Container(
      margin: const EdgeInsets.only(
        top: Base.BASE_PADDING,
      ),
      child: Row(
        children: defaultUserWidgets,
      ),
    );

    List<Widget> memberList = [];
    for (var i = 0; i < 3; i++) {
      memberList.add(Container(
        margin: EdgeInsets.only(left: Base.BASE_PADDING_HALF),
        child: UserPicComponent(width: 30),
      ));
    }
    memberList.add(Expanded(child: Container()));
    memberList.add(GestureDetector(
      child: Icon(Icons.chevron_right),
    ));
    var memberListWidget = Container(
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

    List<Widget> appList = [];
    appList.add(Container(
      child: MeRouterAppItemComponent(),
    ));
    appList.add(Divider());
    appList.add(Container(
      child: MeRouterAppItemComponent(),
    ));
    appList.add(Divider());
    appList.add(Container(
      child: MeRouterAppItemComponent(),
    ));
    appList.add(Divider());
    appList.add(Container(
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
        children: appList,
      ),
    );

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
