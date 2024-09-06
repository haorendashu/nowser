import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/const/auth_result.dart';
import 'package:nowser/const/auth_type.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/data/auth_log.dart';
import 'package:nowser/provider/app_provider.dart';
import 'package:provider/provider.dart';

class MeRouterLogItemComponent extends StatefulWidget {
  AuthLog authLog;

  MeRouterLogItemComponent(this.authLog);

  @override
  State<StatefulWidget> createState() {
    return _MeRouterLogItemComponent();
  }
}

class _MeRouterLogItemComponent extends State<MeRouterLogItemComponent> {
  @override
  Widget build(BuildContext context) {
    var appProvider = Provider.of<AppProvider>(context);
    var app = appProvider.getAppById(widget.authLog.appId!);

    var appName = "";
    if (app != null) {
      if (StringUtil.isNotBlank(app.name)) {
        appName = app.name!;
      } else if (StringUtil.isNotBlank(app.code)) {
        appName = app.code!;
      }
    }

    var appNameWidget = Container(
      constraints: BoxConstraints(maxWidth: 80),
      margin: EdgeInsets.only(
        left: Base.BASE_PADDING_HALF,
        right: Base.BASE_PADDING_HALF,
      ),
      child: Text(
        appName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    late Widget resultWidget;
    if (widget.authLog.authResult == AuthResult.OK) {
      resultWidget = Card.filled(
        color: Colors.green,
        child: Container(
          padding: EdgeInsets.only(
            left: Base.BASE_PADDING_HALF,
            right: Base.BASE_PADDING_HALF,
            top: 2,
            bottom: 2,
          ),
          child: Text(
            "approve",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      resultWidget = Card.filled(
        color: Colors.red,
        child: Container(
          padding: EdgeInsets.only(
            left: Base.BASE_PADDING_HALF,
            right: Base.BASE_PADDING_HALF,
          ),
          child: Text(
            "reject",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    String authContent = "";
    var authType = widget.authLog.authType!;
    authContent += AuthType.getAuthName(context, authType);

    if (authType == AuthType.SIGN_EVENT) {
      authContent += " EventKind(${widget.authLog.eventKind})";
    } else if (authType >= AuthType.NIP04_ENCRYPT) {
      if (StringUtil.isNotBlank(widget.authLog.content)) {
        authContent += widget.authLog.content!;
      }
    }

    var logWidget = Expanded(
        child: Container(
      child: Text(
        authContent,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ));

    var rightIconWidget = Container(
      child: Icon(Icons.chevron_right),
    );

    return Container(
      child: Row(
        children: [
          appNameWidget,
          Container(
            margin: EdgeInsets.only(right: Base.BASE_PADDING_HALF),
            child: resultWidget,
          ),
          logWidget,
          rightIconWidget,
        ],
      ),
    );
  }
}
