import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/cust_state.dart';
import 'package:nowser/component/text_input/text_input_dialog.dart';
import 'package:nowser/component/user/user_name_component.dart';
import 'package:nowser/component/user/user_pic_component.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/const/router_path.dart';
import 'package:nowser/data/auth_log_db.dart';
import 'package:nowser/data/bookmark_db.dart';
import 'package:nowser/data/browser_history_db.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/app_provider.dart';
import 'package:nowser/provider/key_provider.dart';
import 'package:nowser/router/me/me_router_log_item_component.dart';
import 'package:nowser/router/me/me_router_web_item_component.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../data/auth_log.dart';
import '../../generated/l10n.dart';
import '../keys/keys_router.dart';
import 'me_router_app_item_component.dart';

class MeRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeRouter();
  }
}

class _MeRouter extends CustState<MeRouter> {
  List<AuthLog> authLogs = [];

  late S s;

  @override
  Future<void> onReady(BuildContext context) async {
    var list = await AuthLogDB.list(skip: 0, limit: 10);
    setState(() {
      authLogs = list;
    });

    updateNumber();
  }

  int? bookmarkNum = 0;

  int? historyNum = 0;

  int? downloadNum = 0;

  Future<void> updateNumber() async {
    bookmarkNum = await BookmarkDB.total();
    historyNum = await BrowserHistoryDB.total();
    downloadNum = downloadProvider.allRecords.length;
    setState(() {});
  }

  @override
  Widget doBuild(BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var _appProvider = Provider.of<AppProvider>(context);
    var _keyProvider = Provider.of<KeyProvider>(context);
    s = S.of(context);

    var listWidgetMargin = const EdgeInsets.only(
      top: Base.BASE_PADDING,
      bottom: Base.BASE_PADDING,
    );

    var pubkeys = _keyProvider.pubkeys;
    String defaultPubkey = "";
    if (pubkeys.isNotEmpty) {
      defaultPubkey = pubkeys.first;
    }

    List<Widget> defaultUserWidgets = [];
    defaultUserWidgets.add(Container(
      margin: const EdgeInsets.only(
        left: Base.BASE_PADDING,
      ),
      child: UserPicComponent(pubkey: defaultPubkey, width: 50),
    ));
    Widget addOrNameWidget = GestureDetector(
      onTap: () {
        KeysRouter.addKey(context);
      },
      child: Text(s.Click_and_Login),
    );
    if (StringUtil.isNotBlank(defaultPubkey)) {
      addOrNameWidget = UserNameComponent(defaultPubkey);
    }
    defaultUserWidgets.add(Container(
      margin: const EdgeInsets.only(left: Base.BASE_PADDING),
      child: addOrNameWidget,
    ));
    defaultUserWidgets.add(Expanded(child: Container()));
    defaultUserWidgets.add(Container(
      margin: const EdgeInsets.only(right: Base.BASE_PADDING),
      child: GestureDetector(
        onTap: () {
          RouterUtil.router(context, RouterPath.SETTING);
        },
        child: const Icon(Icons.settings),
      ),
    ));
    var defaultUserWidget = Container(
      margin: const EdgeInsets.only(
        top: Base.BASE_PADDING,
      ),
      child: GestureDetector(
        onTap: () {
          RouterUtil.router(context, RouterPath.KEYS);
        },
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: defaultUserWidgets,
        ),
      ),
    );

    Widget memberListWidget = Container(
      height: Base.BASE_PADDING,
    );
    if (pubkeys.length > 1) {
      List<Widget> memberList = [];
      for (var pubkey in pubkeys) {
        memberList.add(Container(
          margin: const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
          child: UserPicComponent(pubkey: pubkey, width: 30),
        ));
      }
      memberList.add(Expanded(child: Container()));
      memberList.add(GestureDetector(
        child: const Icon(Icons.chevron_right),
      ));
      memberListWidget = Container(
        decoration: BoxDecoration(
          color: themeData.cardColor,
          borderRadius: BorderRadius.circular(
            Base.BASE_PADDING,
          ),
        ),
        margin: listWidgetMargin,
        padding: const EdgeInsets.all(Base.BASE_PADDING),
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
    }

    List<Widget> webItemList = [];
    webItemList.add(MeRouterWebItemComponent(
      num: bookmarkNum,
      name: s.Bookmarks,
      iconData: Icons.bookmark,
      onTap: () async {
        var url = await RouterUtil.router(context, RouterPath.BOOKMARK);
        if (webProvider.currentGoTo(url)) {
          RouterUtil.back(context);
        }
      },
    ));
    webItemList.add(MeRouterWebItemComponent(
      num: historyNum,
      name: s.Historys,
      iconData: Icons.history,
      onTap: () async {
        var url = await RouterUtil.router(context, RouterPath.HISTORY);
        if (webProvider.currentGoTo(url)) {
          RouterUtil.back(context);
        }
      },
    ));
    webItemList.add(MeRouterWebItemComponent(
      num: downloadNum,
      name: s.Downloads,
      iconData: Icons.download,
      onTap: () {
        RouterUtil.router(context, RouterPath.DOWNLOADS);
      },
    ));
    webItemList.add(GestureDetector(
      onTap: () {
        RouterUtil.router(context, RouterPath.APPS, "addRemote");
      },
      child: Container(
        alignment: Alignment.center,
        // margin: widget.margin,
        child: Container(
          width: 80,
          padding: const EdgeInsets.only(
            left: Base.BASE_PADDING,
            right: Base.BASE_PADDING,
            top: Base.BASE_PADDING,
            bottom: Base.BASE_PADDING,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(Base.BASE_PADDING),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(
                  bottom: Base.BASE_PADDING_HALF,
                ),
                child: Icon(Icons.add),
              ),
              Text(
                "Add",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: themeData.textTheme.bodySmall!.fontSize! - 2,
                ),
              ),
              Text(
                "Remote",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: themeData.textTheme.bodySmall!.fontSize! - 2,
                ),
              ),
            ],
          ),
        ),
      ),
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
    var appListLength = appList.length;
    for (var i = 0; i < appListLength && i < 5; i++) {
      var app = appList[i];
      appWidgetList.add(Container(
        child: MeRouterAppItemComponent(app),
      ));
      appWidgetList.add(Divider());
    }
    if (appWidgetList.isEmpty) {
      appWidgetList.add(GestureDetector(
        onTap: () {
          RouterUtil.router(context, RouterPath.APPS);
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          child: Text(s.no_apps_now),
        ),
      ));
      appWidgetList.add(Divider());
    }
    appWidgetList.add(Container(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          RouterUtil.router(context, RouterPath.APPS);
        },
        behavior: HitTestBehavior.translucent,
        child: Text(
          s.Show_more_apps,
          style: TextStyle(
            decoration: TextDecoration.underline,
          ),
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
    for (var authLog in authLogs) {
      logList.add(Container(
        child: MeRouterLogItemComponent(authLog),
      ));
      logList.add(Divider());
    }
    if (logList.isEmpty) {
      logList.add(Container(
        child: Text(s.no_logs_now),
      ));
      logList.add(Divider());
    }
    logList.add(Container(
      alignment: Alignment.center,
      child: Text(
        s.Show_more_logs,
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
          top: mediaQueryData.padding.top + 30,
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
          )
        ],
      ),
    );
  }
}
