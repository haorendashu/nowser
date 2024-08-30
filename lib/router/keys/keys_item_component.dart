import 'package:flutter/material.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nowser/const/base.dart';

import '../../component/user_pic_component.dart';

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
      margin: EdgeInsets.only(
        right: Base.BASE_PADDING_HALF,
      ),
      child: UserPicComponent(
        width: 26,
      ),
    ));
    list.add(Expanded(
        child: Text(
      Nip19.encodePubKey(widget.pubkey),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    )));
    list.add(Container(
      margin: EdgeInsets.only(
        left: Base.BASE_PADDING_HALF,
        // right: Base.BASE_PADDING_HALF,
      ),
      child: Icon(Icons.logout),
    ));

    return Container(
      padding: EdgeInsets.all(Base.BASE_PADDING),
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
