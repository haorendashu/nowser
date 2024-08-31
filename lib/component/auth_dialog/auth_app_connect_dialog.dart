import 'package:flutter/material.dart';
import 'package:nowser/component/auth_dialog/auth_dialog_base_componnet.dart';
import 'package:nowser/const/connect_type.dart';

import '../../const/base.dart';

class AuthAppConnectDialog extends StatefulWidget {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AuthAppConnectDialog();
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

    return AuthDialogBaseComponnet(title: "App Connect", child: child);
  }

  void onConnectTypeChange(int? value) {
    if (value != null) {
      setState(() {
        connectType = value;
      });
    }
  }
}
