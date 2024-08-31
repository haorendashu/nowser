import 'package:flutter/material.dart';
import 'package:nowser/component/auth_dialog/auth_dialog_base_componnet.dart';

import '../../const/base.dart';

class AuthDialog extends StatefulWidget {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AuthDialog();
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _AuthDialog();
  }
}

class _AuthDialog extends State<AuthDialog> {
  bool showDetail = false;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var baseMargin = EdgeInsets.only(
      top: Base.BASE_PADDING_HALF,
      bottom: Base.BASE_PADDING_HALF,
    );
    var hintColor = themeData.hintColor;

    List<Widget> list = [];
    list.add(Container(
      margin: baseMargin,
      child: Text(
        "Allow web.nostrmo.com to sign a authenticate event",
      ),
    ));

    var showDetailWidget = GestureDetector(
      onTap: () {
        setState(() {
          showDetail = !showDetail;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("detail"),
          showDetail ? Icon(Icons.expand_less) : Icon(Icons.expand_more),
        ],
      ),
    );

    List<Widget> detailList = [];
    if (showDetail) {
      detailList.add(Container(
        height: 210,
        width: double.infinity,
        padding: EdgeInsets.all(Base.BASE_PADDING_HALF),
        decoration: BoxDecoration(
          color: hintColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Text(
              "GoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGoodGood"),
        ),
      ));
    } else {}
    detailList.add(Container(
      margin: baseMargin,
      child: showDetailWidget,
    ));

    list.add(Container(
      height: 250,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: detailList,
      ),
    ));

    var child = Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );

    return AuthDialogBaseComponnet(title: "Sign Event", child: child);
  }
}
