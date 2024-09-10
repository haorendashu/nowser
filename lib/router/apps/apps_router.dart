import 'package:flutter/material.dart';
import 'package:nowser/const/router_path.dart';
import 'package:nowser/provider/app_provider.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../const/base.dart';
import '../me/me_router_app_item_component.dart';

class AppsRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppsRouter();
  }
}

class _AppsRouter extends State<AppsRouter> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var _appProvider = Provider.of<AppProvider>(context);
    var appList = _appProvider.appList;

    var main = ListView.builder(
      itemBuilder: (context, index) {
        if (index >= appList.length) {
          return null;
        }

        var app = appList[index];
        return Container(
          child: MeRouterAppItemComponent(app),
        );
      },
      itemCount: appList.length,
    );

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
          )
        ],
      ),
    );
  }
}
