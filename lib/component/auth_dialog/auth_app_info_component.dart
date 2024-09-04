import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/const/app_type.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/data/app.dart';

import '../app/app_type_component.dart';

class AuthAppInfoComponent extends StatefulWidget {
  App app;

  AuthAppInfoComponent({required this.app});

  @override
  State<StatefulWidget> createState() {
    return _AuthAppInfoComponent();
  }
}

class _AuthAppInfoComponent extends State<AuthAppInfoComponent> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    String? name;
    String? des;
    if (StringUtil.isNotBlank(widget.app.name)) {
      name = widget.app.name;
      des = widget.app.code;
    } else if (StringUtil.isBlank(widget.app.name)) {
      name = widget.app.code;
    }

    List<Widget> rightList = [];
    if (StringUtil.isNotBlank(name)) {
      rightList.add(Text(
        name!,
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
    }
    if (StringUtil.isNotBlank(des)) {
      rightList.add(Text(des!));
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 64,
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(Base.BASE_PADDING_HALF),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin:
                        const EdgeInsets.only(right: Base.BASE_PADDING_HALF),
                    child: Icon(
                      Icons.image,
                      size: 46,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rightList,
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          child: AppTypeComponent(AppType.WEB),
        )
      ],
    );
  }
}
