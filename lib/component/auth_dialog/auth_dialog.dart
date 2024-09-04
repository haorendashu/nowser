import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/auth_dialog/auth_dialog_base_componnet.dart';
import 'package:nowser/const/auth_result.dart';
import 'package:nowser/data/app.dart';
import 'package:nowser/util/router_util.dart';

import '../../const/base.dart';

class AuthDialog extends StatefulWidget {
  App app;

  int authType;

  int? eventKind;

  String? authDetail;

  AuthDialog({
    required this.app,
    required this.authType,
    this.eventKind,
    this.authDetail,
  });

  static Future<int?> show(BuildContext context, App app, int authType,
      {int? eventKind, String? authDetail}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AuthDialog(
          app: app,
          authType: authType,
          eventKind: eventKind,
          authDetail: authDetail,
        );
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

    // handle this title and des with widget.authType
    String authTitle = "Sign Event";
    String authDes = "Allow web.nostrmo.com to sign a authenticate event";
    authTitle = "AuthType ${widget.authType}";

    List<Widget> list = [];
    list.add(Container(
      margin: baseMargin,
      child: Text(
        authDes,
      ),
    ));

    List<Widget> detailList = [];
    if (StringUtil.isNotBlank(widget.authDetail)) {
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
            child: Text(widget.authDetail!),
          ),
        ));
      } else {}
      detailList.add(Container(
        margin: baseMargin,
        child: showDetailWidget,
      ));
    }

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

    return AuthDialogBaseComponnet(
      app: widget.app,
      title: authTitle,
      onConfirm: onConfirm,
      child: child,
    );
  }

  onConfirm() {
    print("auth dialog confirm!");
    RouterUtil.back(context, AuthResult.OK);
  }
}
