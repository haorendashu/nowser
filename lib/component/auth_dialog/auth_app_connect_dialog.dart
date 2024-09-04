import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/auth_dialog/auth_dialog_base_componnet.dart';
import 'package:nowser/const/connect_type.dart';
import 'package:nowser/const/reasonable_permissions.dart';
import 'package:nowser/data/app_db.dart';
import 'package:nowser/main.dart';
import 'package:nowser/util/router_util.dart';

import '../../const/base.dart';
import '../../data/app.dart';

class AuthAppConnectDialog extends StatefulWidget {
  App app;

  AuthAppConnectDialog({required this.app});

  static Future<App?> show(BuildContext context, App app) {
    return showDialog(
      context: context,
      builder: (context) {
        return AuthAppConnectDialog(
          app: app,
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _AuthAppConnectDialog();
  }
}

class _AuthAppConnectDialog extends State<AuthAppConnectDialog> {
  int connectType = ConnectType.REASONABLE;

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

    list.add(RadioListTile(
      value: ConnectType.FULLY_TRUST,
      groupValue: connectType,
      onChanged: onConnectTypeChange,
      title: Text("I fully trust it"),
      subtitle: Text("Auto-sign all requests (except payments)"),
    ));

    list.add(RadioListTile(
      value: ConnectType.REASONABLE,
      groupValue: connectType,
      onChanged: onConnectTypeChange,
      title: Text("Let's be reasonable"),
      subtitle: Text("Auto-approve most common requests"),
    ));

    list.add(RadioListTile(
      value: ConnectType.ALWAY_REJECT,
      groupValue: connectType,
      onChanged: onConnectTypeChange,
      title: Text("I'm a bit paranoid"),
      subtitle: Text("Do not sign anything without asking me!"),
    ));

    var child = Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );

    return AuthDialogBaseComponnet(
      app: widget.app,
      title: "App Connect",
      onConfirm: onConfirm,
      child: child,
    );
  }

  void onConnectTypeChange(int? value) {
    if (value != null) {
      setState(() {
        connectType = value;
      });
    }
  }

  onConfirm() async {
    var app = widget.app;
    app.connectType = connectType;
    if (StringUtil.isBlank(app.pubkey) && keyProvider.pubkeys.isNotEmpty) {
      app.pubkey = keyProvider.pubkeys.first;
    }
    if (connectType == ConnectType.REASONABLE) {
      app.alwaysAllow = ReasonablePermissions.text;
    }
    app.createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    app.updatedAt = app.createdAt;

    if (await AppDB.insert(app) > 0) {
      await appProvider.reload();
      RouterUtil.back(context);
    }
  }
}
