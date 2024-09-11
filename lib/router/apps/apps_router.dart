import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nostr_sdk/client_utils/keys.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nostr_sdk/utils/date_format_util.dart';
import 'package:nowser/component/cust_state.dart';
import 'package:nowser/component/tag_component.dart';
import 'package:nowser/const/app_type.dart';
import 'package:nowser/const/router_path.dart';
import 'package:nowser/data/remote_signing_info_db.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/app_provider.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../component/app/app_type_component.dart';
import '../../component/appbar_back_btn_component.dart';
import '../../const/base.dart';
import '../../data/remote_signing_info.dart';
import '../me/me_router_app_item_component.dart';

class AppsRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppsRouter();
  }
}

class _AppsRouter extends CustState<AppsRouter> {
  @override
  Widget doBuild(BuildContext context) {
    var themeData = Theme.of(context);
    var _appProvider = Provider.of<AppProvider>(context);
    var appList = _appProvider.appList;

    List<Widget> mainList = [];

    if (appList.isNotEmpty) {
      List<Widget> widgets = [];
      var length = appList.length;
      for (var i = 0; i < length; i++) {
        var app = appList[i];
        widgets.add(Container(
          child: MeRouterAppItemComponent(app),
        ));
        if (i + 1 < length) {
          widgets.add(Divider());
        }
      }
      if (widgets.isNotEmpty) {
        var listWidget = Container(
          padding: EdgeInsets.all(Base.BASE_PADDING),
          decoration: BoxDecoration(
            color: themeData.cardColor,
            borderRadius: BorderRadius.circular(
              Base.BASE_PADDING,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widgets,
          ),
        );

        mainList.add(SliverToBoxAdapter(child: listWidget));
      }
    }

    List<RemoteSigningInfo> penddingList =
        remoteSigningProvider.penddingRemoteApps;
    if (penddingList.isNotEmpty) {
      List<Widget> widgets = [];
      var length = penddingList.length;
      for (var i = 0; i < length; i++) {
        var remoteSigningInfo = penddingList[i];
        if (StringUtil.isBlank(remoteSigningInfo.remotePubkey)) {
          continue;
        }

        String connectUrlType = "bunker";
        if (StringUtil.isNotBlank(remoteSigningInfo.localPubkey)) {
          connectUrlType = "nostrconnect";
        }

        widgets.add(Container(
          child: Row(
            children: [
              Text(Nip19.encodeSimplePubKey(remoteSigningInfo.remotePubkey!)),
              Expanded(
                  child: Container(
                margin: const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
                child: Text(
                  DateFormatUtil.format(
                    remoteSigningInfo.createdAt!,
                  ),
                  style: TextStyle(
                    color: themeData.hintColor,
                  ),
                ),
              )),
              Container(
                margin: const EdgeInsets.only(right: Base.BASE_PADDING),
                child: TagComponent(connectUrlType),
              ),
              AppTypeComponent(AppType.REMOTE),
            ],
          ),
        ));

        if (i + 1 < length) {
          widgets.add(Divider());
        }
      }

      if (widgets.isNotEmpty) {
        mainList.add(SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.only(top: Base.BASE_PADDING),
            child: Text(
              "Pendding connect remote apps",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));

        var listWidget = Container(
          margin: EdgeInsets.only(top: Base.BASE_PADDING),
          padding: EdgeInsets.all(Base.BASE_PADDING),
          decoration: BoxDecoration(
            color: themeData.cardColor,
            borderRadius: BorderRadius.circular(
              Base.BASE_PADDING,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widgets,
          ),
        );

        mainList.add(SliverToBoxAdapter(child: listWidget));
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackBtnComponent(),
        title: Text(
          "Apps Manager",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: themeData.textTheme.bodyLarge!.fontSize,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              RouterUtil.router(context, RouterPath.ADD_REMOTE_APP);
            },
            child: Container(
              padding: const EdgeInsets.all(Base.BASE_PADDING),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(Base.BASE_PADDING),
        child: CustomScrollView(
          slivers: mainList,
        ),
      ),
    );
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}
