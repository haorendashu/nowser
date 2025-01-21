import 'package:flutter/material.dart';
import 'package:nowser/component/appbar_back_btn_component.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/key_provider.dart';
import 'package:nowser/router/keys/keys_item_component.dart';
import 'package:provider/provider.dart';

import '../../component/user/user_login_dialog.dart';
import '../../generated/l10n.dart';

class KeysRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _KeysRouter();
  }

  static void addKey(BuildContext context) {
    UserLoginDialog.show(context);
  }
}

class _KeysRouter extends State<KeysRouter> {
  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    var themeData = Theme.of(context);
    var margin = const EdgeInsets.only(
      left: Base.BASE_PADDING,
      right: Base.BASE_PADDING,
      top: Base.BASE_PADDING,
    );

    var _keyProvider = Provider.of<KeyProvider>(context);

    List<Widget> list = [];
    var pubkeys = _keyProvider.pubkeys;
    var length = pubkeys.length;
    for (var i = 0; i < length; i++) {
      var pubkey = pubkeys[i];
      list.add(Container(
        margin: margin,
        child: GestureDetector(
          onTap: () {
            keyProvider.setDefault(pubkey);
          },
          child: KeysItemComponent(
            pubkey,
            isDefault: i == 0,
          ),
        ),
      ));
    }

    var main = ListView(
      children: list,
    );

    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackBtnComponent(),
        title: Text(
          s.Keys_Manager,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: themeData.textTheme.bodyLarge!.fontSize,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              KeysRouter.addKey(context);
            },
            child: Container(
              padding: const EdgeInsets.all(Base.BASE_PADDING),
              child: Icon(Icons.add),
            ),
          )
        ],
      ),
      body: main,
    );
  }
}
