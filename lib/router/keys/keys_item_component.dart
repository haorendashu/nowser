import 'package:flutter/material.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/main.dart';

import '../../component/user/user_name_component.dart';
import '../../component/user/user_pic_component.dart';

class KeysItemComponent extends StatefulWidget {
  bool isDefault;

  String pubkey;

  KeysItemComponent(this.pubkey, {this.isDefault = false});

  @override
  State<StatefulWidget> createState() {
    return _KeysItemComponent();
  }
}

class _KeysItemComponent extends State<KeysItemComponent> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    List<Widget> list = [];

    list.add(Container(
      margin: const EdgeInsets.only(
        right: Base.BASE_PADDING_HALF,
      ),
      child: UserPicComponent(
        pubkey: widget.pubkey,
        width: 26,
      ),
    ));
    list.add(Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
        child: UserNameComponent(
          widget.pubkey,
          fullNpubName: true,
          showBoth: true,
        ),
      ),
    ));
    list.add(GestureDetector(
      onTap: () {
        keyProvider.removeKey(widget.pubkey);
      },
      child: Container(
        margin: const EdgeInsets.only(
          left: Base.BASE_PADDING_HALF,
        ),
        child: const Icon(Icons.logout),
      ),
    ));

    return Container(
      padding: const EdgeInsets.all(Base.BASE_PADDING),
      decoration: BoxDecoration(
        color:
            widget.isDefault ? mainColor.withOpacity(0.5) : themeData.cardColor,
        borderRadius: BorderRadius.circular(Base.BASE_PADDING),
      ),
      child: Row(
        children: list,
      ),
    );
  }
}
