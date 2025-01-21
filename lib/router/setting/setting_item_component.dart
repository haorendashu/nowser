import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';

import '../../const/base.dart';

class SettingItemComponent extends StatelessWidget {
  String title;

  String? value;

  Widget? child;

  bool showTopBorder;

  Function? onTap;

  SettingItemComponent(
    this.title, {
    this.value,
    this.child,
    this.showTopBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    if (child == null && StringUtil.isNotBlank(value)) {
      child = Text(value!);
    }
    child ??= Container();

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: Base.BASE_PADDING_HALF,
          right: Base.BASE_PADDING_HALF,
          top: 10,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          border: showTopBorder
              ? Border(
                  top: BorderSide(
                    color: themeData.dividerColor,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              child: Text(title),
            ),
            Expanded(child: Container()),
            Container(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
