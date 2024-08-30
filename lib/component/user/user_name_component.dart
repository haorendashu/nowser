import 'package:flutter/material.dart';
import 'package:nostr_sdk/nip19/nip19.dart';

class UserNameComponent extends StatefulWidget {
  String pubkey;

  bool fullNpubName;

  UserNameComponent(this.pubkey, {this.fullNpubName = false});

  @override
  State<StatefulWidget> createState() {
    return _UserNameComponent();
  }
}

class _UserNameComponent extends State<UserNameComponent> {
  @override
  Widget build(BuildContext context) {
    var npub = Nip19.encodePubKey(widget.pubkey);
    if (!widget.fullNpubName) {
      npub = Nip19.encodeSimplePubKey(widget.pubkey);
    }

    return Text(
      npub,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
