import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/auth_dialog/auth_dialog_base_componnet.dart';
import 'package:nowser/const/auth_result.dart';
import 'package:nowser/const/auth_type.dart';
import 'package:nowser/data/app.dart';
import 'package:nowser/main.dart';
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

  bool always = false;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var baseMargin = EdgeInsets.only(
      top: Base.BASE_PADDING_HALF,
      bottom: Base.BASE_PADDING_HALF,
    );
    var hintColor = themeData.hintColor;

    var appName = widget.app.name;
    if (StringUtil.isNotBlank(widget.app.code)) {
      appName = widget.app.code;
    }
    // handle this title and des with widget.authType
    String authTitle = "Sign Event";
    String authDes = "Allow $appName to ";
    if (widget.authType == AuthType.GET_PUBLIC_KEY) {
      authTitle = "Get Public Key";
      authDes += "get public key";
    } else if (widget.authType == AuthType.SIGN_EVENT) {
      authTitle = "Sign Event";
      authDes += "sign a ${widget.eventKind} event";
    } else if (widget.authType == AuthType.GET_RELAYS) {
      authTitle = "Get Relays";
      authDes += "get relays";
    } else if (widget.authType == AuthType.NIP04_ENCRYPT) {
      authTitle = "Encrypt (NIP-04)";
      authDes += "Encrypt (NIP-04)";
    } else if (widget.authType == AuthType.NIP04_DECRYPT) {
      authTitle = "Decrypt (NIP-04)";
      authDes += "Decrypt (NIP-04)";
    } else if (widget.authType == AuthType.NIP44_ENCRYPT) {
      authTitle = "Encrypt (NIP-44)";
      authDes += "Encrypt (NIP-44)";
    } else if (widget.authType == AuthType.NIP44_DECRYPT) {
      authTitle = "Decrypt (NIP-44)";
      authDes += "Decrypt (NIP-44)";
    }

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
          height: 142,
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
      height: 180,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: detailList,
      ),
    ));

    list.add(Container(
      child: GestureDetector(
        onTap: () {
          setState(() {
            always = !always;
          });
        },
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: [
            Checkbox(
              value: always,
              onChanged: (v) {
                setState(() {
                  always = v!;
                });
              },
            ),
            Text("Always"),
          ],
        ),
      ),
    ));

    var child = Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );

    return AuthDialogBaseComponnet(
      app: widget.app,
      title: authTitle,
      onReject: onReject,
      onConfirm: onConfirm,
      pubkeyReadonly: true,
      child: child,
    );
  }

  onReject() {
    if (always) {
      // always do reject this
      appProvider.alwaysReject(widget.app.appType!, widget.app.code!,
          widget.authType, widget.eventKind);
    }

    RouterUtil.back(context);
  }

  onConfirm() {
    if (always) {
      // always do confirm this
      appProvider.alwaysAllow(widget.app.appType!, widget.app.code!,
          widget.authType, widget.eventKind);
    }

    RouterUtil.back(context, AuthResult.OK);
  }
}
