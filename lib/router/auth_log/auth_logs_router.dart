import 'package:flutter/material.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../component/deletable_list_mixin.dart';

class AuthLogsRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthLogsRouter();
  }
}

class _AuthLogsRouter extends State<AuthLogsRouter> with DeletableListMixin {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackBtnComponent(),
        title: Text(
          "Auth Logs",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: themeData.textTheme.bodyLarge!.fontSize,
          ),
        ),
        actions: genAppBarActions(context),
      ),
      body: Container(),
    );
  }
}
