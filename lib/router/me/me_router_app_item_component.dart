import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/app/app_type_component.dart';
import 'package:nowser/component/image_component.dart';
import 'package:nowser/const/app_type.dart';
import 'package:nowser/const/router_path.dart';
import 'package:nowser/data/app.dart';
import 'package:nowser/util/router_util.dart';

import '../../const/base.dart';

class MeRouterAppItemComponent extends StatefulWidget {
  App app;

  MeRouterAppItemComponent(this.app);

  @override
  State<StatefulWidget> createState() {
    return _MeRouterAppItemComponent();
  }
}

class _MeRouterAppItemComponent extends State<MeRouterAppItemComponent> {
  @override
  Widget build(BuildContext context) {
    var imageWidget = Container(
      margin: const EdgeInsets.only(
        left: Base.BASE_PADDING_HALF,
        right: Base.BASE_PADDING_HALF,
      ),
      child: StringUtil.isBlank(widget.app.image)
          ? const Icon(Icons.image)
          : ImageComponent(
              imageUrl: widget.app.image!,
              width: 30,
              height: 30,
            ),
    );

    var appName = widget.app.name;
    if (StringUtil.isBlank(appName)) {
      appName = widget.app.code;
    }

    var titleWidget = Container(
      margin: const EdgeInsets.only(right: Base.BASE_PADDING_HALF),
      child: Text(
        appName!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    var typeWidget = Container(
      child: AppTypeComponent(widget.app.appType!),
    );

    var rightIconWidget = Container(
      child: Icon(Icons.chevron_right),
    );

    return GestureDetector(
      onTap: () {
        RouterUtil.router(context, RouterPath.APP_DETAIL, widget.app);
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        child: Row(
          children: [
            imageWidget,
            Expanded(child: titleWidget),
            typeWidget,
            rightIconWidget,
          ],
        ),
      ),
    );
  }
}
