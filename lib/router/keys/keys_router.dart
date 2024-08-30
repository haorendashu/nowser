import 'package:flutter/material.dart';
import 'package:nowser/component/appbar_back_btn_component.dart';
import 'package:nowser/component/text_input/text_input_dialog.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/router/keys/keys_item_component.dart';

class KeysRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _KeysRouter();
  }

  static void addKey(BuildContext context) {
    TextInputDialog.show(context, "Please input private key");
  }
}

class _KeysRouter extends State<KeysRouter> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var margin = EdgeInsets.only(
      left: Base.BASE_PADDING,
      right: Base.BASE_PADDING,
      top: Base.BASE_PADDING,
    );

    List<Widget> list = [];
    list.add(Container(
      margin: margin,
      child: KeysItemComponent(
        "29320975df855fe34a7b45ada2421e2c741c37c0136901fe477133a91eb18b07",
        isDefault: true,
      ),
    ));
    for (var i = 0; i < 5; i++) {
      list.add(Container(
        margin: margin,
        child: KeysItemComponent(
          "8fb140b4e8ddef97ce4b821d247278a1a4353362623f64021484b372f948000c",
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
          "Keys Manager",
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
