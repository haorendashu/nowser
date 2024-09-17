import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/image_component.dart';
import 'package:nowser/const/app_type.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/data/app.dart';

import 'app_type_component.dart';

class SimpleAppInfoComponent extends StatefulWidget {
  App app;

  SimpleAppInfoComponent({required this.app});

  @override
  State<StatefulWidget> createState() {
    return _SimpleAppInfoComponent();
  }
}

class _SimpleAppInfoComponent extends State<SimpleAppInfoComponent> {
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ));
    }
    if (StringUtil.isNotBlank(des)) {
      rightList.add(Text(
        des!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ));
    }

    return Container(
      width: double.infinity,
      height: 64,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(Base.BASE_PADDING_HALF),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: Base.BASE_PADDING_HALF),
                child: StringUtil.isBlank(widget.app.image)
                    ? const Icon(
                        Icons.image,
                        size: 46,
                      )
                    : ImageComponent(
                        imageUrl: widget.app.image!,
                        width: 40,
                        height: 40,
                      ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rightList,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: Base.BASE_PADDING_HALF,
                  right: Base.BASE_PADDING_HALF,
                ),
                child: AppTypeComponent(widget.app.appType!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
