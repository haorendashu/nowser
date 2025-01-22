import 'package:flutter/material.dart';
import 'package:nowser/component/tag_component.dart';
import 'package:nowser/const/auth_type.dart';

import '../../generated/l10n.dart';

class AppDetailPermissionItemComponent extends StatefulWidget {
  bool allow;

  int authType;

  int? eventKind;

  Function(bool, int, int?)? onDelete;

  AppDetailPermissionItemComponent(this.allow, this.authType,
      {this.eventKind, this.onDelete});

  @override
  State<StatefulWidget> createState() {
    return _AppDetailPermissionItemComponent();
  }
}

class _AppDetailPermissionItemComponent
    extends State<AppDetailPermissionItemComponent> {
  bool tapFirst = false;

  late S s;

  @override
  Widget build(BuildContext context) {
    s = S.of(context);
    var permissionText = AuthType.getAuthName(context, widget.authType);
    if (widget.eventKind != null) {
      permissionText += " (${s.EventKind} ${widget.eventKind})";
    }
    var main = TagComponent(permissionText);

    if (!tapFirst) {
      return GestureDetector(
        onTap: () {
          setState(() {
            tapFirst = true;
          });
        },
        child: main,
      );
    }

    return GestureDetector(
      onTap: () {
        if (widget.onDelete != null) {
          widget.onDelete!(widget.allow, widget.authType, widget.eventKind);
        }
      },
      child: Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            main,
            Icon(Icons.delete),
          ],
        ),
      ),
    );
  }
}
