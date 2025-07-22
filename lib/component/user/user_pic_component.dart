import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:provider/provider.dart';

import '../../data/metadata.dart';
import '../../provider/userinfo_provider.dart';
import '../image_component.dart';

class UserPicComponent extends StatefulWidget {
  String pubkey;

  double width;

  UserPicComponent({
    required this.pubkey,
    required this.width,
  });

  @override
  State<StatefulWidget> createState() {
    return _UserPicComponent();
  }
}

class _UserPicComponent extends State<UserPicComponent> {
  @override
  Widget build(BuildContext context) {
    return Selector<UserinfoProvider, Metadata?>(
        builder: (context, metadata, child) {
      Widget innerWidget = Icon(
        Icons.account_circle,
        size: widget.width,
      );

      if (metadata != null && StringUtil.isNotBlank(metadata.picture)) {
        innerWidget = ImageComponent(
          imageUrl: metadata.picture!,
          width: widget.width,
          height: widget.width,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
        );
      }

      return Container(
        width: widget.width,
        height: widget.width,
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.width / 2),
        ),
        child: innerWidget,
      );
    }, selector: (context, _provider) {
      if (StringUtil.isNotBlank(widget.pubkey)) {
        return _provider.getMetadata(widget.pubkey);
      }
    });
  }
}
