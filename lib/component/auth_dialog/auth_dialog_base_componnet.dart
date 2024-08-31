import 'package:flutter/material.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/util/router_util.dart';

import '../logo_component.dart';
import 'auth_app_info_component.dart';

class AuthDialogBaseComponnet extends StatefulWidget {
  String title;

  Widget child;

  AuthDialogBaseComponnet({required this.title, required this.child});

  @override
  State<StatefulWidget> createState() {
    return _AuthDialog();
  }
}

class _AuthDialog extends State<AuthDialogBaseComponnet> {
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
        widget.title,
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
      child: widget.child,
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
            onPressed: () {
              RouterUtil.back(context);
            },
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
