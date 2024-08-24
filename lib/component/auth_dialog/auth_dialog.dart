import 'package:flutter/material.dart';
import 'package:nowser/const/base.dart';

import '../logo_component.dart';
import 'auth_app_info_component.dart';

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

    var topWidget = Container(
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
              top: Base.BASE_PADDING_HALF,
              bottom: Base.BASE_PADDING_HALF,
            ),
            child: LogoComponent(),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: Base.BASE_PADDING_HALF),
              alignment: Alignment.centerRight,
              child: DropdownButton<String>(
                items: [
                  DropdownMenuItem(
                    child: Text("npubxxxxxx"),
                    value: "npubxxxxxx",
                  )
                ],
                onChanged: (Object? value) {},
                value: "npubxxxxxx",
              ),
            ),
          ),
        ],
      ),
    );

    list.add(Container(
      alignment: Alignment.center,
      margin: baseMargin,
      child: Text(
        "Action Title",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: themeData.textTheme.bodyLarge!.fontSize,
        ),
      ),
    ));

    list.add(Container(
      margin: baseMargin,
      child: AuthAppInfoComponent(),
    ));

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

    list.add(Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FilledButton(onPressed: () {}, child: Text("Cancel")),
          // OutlinedButton(
          //   onPressed: () {},
          //   child: Text(
          //     "Cancel",
          //     style: TextStyle(
          //       color: Colors.red,
          //     ),
          //   ),
          //   style: ,
          // ),
          FilledButton(
            onPressed: () {},
            child: Text("Cancel"),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: Base.BASE_PADDING_HALF,
            ),
            child: FilledButton(onPressed: () {}, child: Text("Confirm")),
          )
        ],
      ),
    ));

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Base.BASE_PADDING),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: hintColor.withOpacity(0.3)))),
            child: topWidget,
          ),
          Container(
            padding: EdgeInsets.all(Base.BASE_PADDING),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: list,
            ),
          ),
        ],
      ),
    );
  }
}
