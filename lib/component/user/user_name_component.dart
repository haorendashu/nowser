import 'package:flutter/material.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/data/metadata.dart';
import 'package:nowser/provider/userinfo_provider.dart';
import 'package:provider/provider.dart';

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
    return Selector<UserinfoProvider, Metadata?>(
        builder: (context, metadata, child) {
      var npub = Nip19.encodePubKey(widget.pubkey);
      if (!widget.fullNpubName) {
        npub = Nip19.encodeSimplePubKey(widget.pubkey);
      }
      var name = npub;

      if (metadata != null) {
        if (StringUtil.isNotBlank(metadata.displayName)) {
          name = metadata.displayName!;
        } else if (StringUtil.isNotBlank(metadata.name)) {
          name = metadata.name!;
        }
      }

      return Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }, selector: (context, _provider) {
      return _provider.getMetadata(widget.pubkey);
    });
  }
}
