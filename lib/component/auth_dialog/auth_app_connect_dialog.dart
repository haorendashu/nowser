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
import '../../generated/l10n.dart';

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

  late S s;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var baseMargin = const EdgeInsets.only(
      top: Base.BASE_PADDING_HALF,
      bottom: Base.BASE_PADDING_HALF,
    );
    var hintColor = themeData.hintColor;
    s = S.of(context);

    List<Widget> list = [];

    list.add(RadioListTile(
      value: ConnectType.FULLY_TRUST,
      groupValue: connectType,
      onChanged: onConnectTypeChange,
      title: Text(s.Full_trust_title),
      subtitle: Text(s.Full_trust_des),
    ));

    list.add(RadioListTile(
      value: ConnectType.REASONABLE,
      groupValue: connectType,
      onChanged: onConnectTypeChange,
      title: Text(s.Reasonable_title),
      subtitle: Text(s.Reasonable_des),
    ));

    list.add(RadioListTile(
      value: ConnectType.ALWAY_REJECT,
      groupValue: connectType,
      onChanged: onConnectTypeChange,
      title: Text(s.Always_reject_title),
      subtitle: Text(s.Always_reject_des),
    ));

    var child = Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );

    return AuthDialogBaseComponnet(
      app: widget.app,
      title: s.App_Connect,
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
