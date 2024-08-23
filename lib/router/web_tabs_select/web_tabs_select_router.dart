import 'package:flutter/material.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/web_provider.dart';
import 'package:nowser/router/web_tabs_select/web_tabs_select_item_component.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import 'web_tabs_clear_all_component.dart';

class WebTabsSelectRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebTabsSelectRouter();
  }
}

class _WebTabsSelectRouter extends State<WebTabsSelectRouter> {
  double bottomBtnBottom = 20;

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var padding = mediaQuery.padding;

    var webProvider = Provider.of<WebProvider>(context);
    var webInfos = webProvider.webInfos;
    List<Widget> list = [];
    for (var webInfo in webInfos) {
      list.add(Container(
        margin: EdgeInsets.only(top: Base.BASE_PADDING),
        child: GestureDetector(
          onTap: () {
            webProvider.changeIndex(webInfo);
            RouterUtil.back(context);
          },
          child: WebTabsSelectItemComponent(webInfo),
        ),
      ));
    }

    var backBtn = GestureDetector(
      onTap: () {
        RouterUtil.back(context);
      },
      child: Container(
        child: Icon(
          Icons.chevron_left,
          size: 30,
        ),
      ),
    );

    var addBtn = GestureDetector(
      onTap: addTab,
      child: Icon(
        Icons.add,
        size: 30,
      ),
    );

    var clearAllBtn = WebTabsClearAllComponent(clearAllTab);

    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.9),
      body: Container(
        padding: EdgeInsets.only(
          top: padding.top,
          bottom: padding.bottom,
          left: Base.BASE_PADDING,
          right: Base.BASE_PADDING,
        ),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Column(
                children: list,
              ),
            ),
            Positioned(
              bottom: bottomBtnBottom,
              left: Base.BASE_PADDING,
              child: backBtn,
            ),
            Positioned(
              bottom: bottomBtnBottom,
              child: addBtn,
            ),
            Positioned(
              bottom: bottomBtnBottom,
              right: Base.BASE_PADDING,
              child: clearAllBtn,
            ),
          ],
        ),
      ),
    );
  }

  void addTab() {
    webProvider.addTab();
    RouterUtil.back(context);
  }

  clearAllTab() {}
}
