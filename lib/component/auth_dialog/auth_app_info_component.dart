import 'package:flutter/material.dart';
import 'package:nowser/const/base.dart';

class AuthAppInfoComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthAppInfoComponent();
  }
}

class _AuthAppInfoComponent extends State<AuthAppInfoComponent> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 64,
          child: Card(
            child: Container(
              padding: EdgeInsets.all(Base.BASE_PADDING_HALF),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: Base.BASE_PADDING_HALF),
                    child: Icon(
                      Icons.image,
                      size: 46,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "APP NAME",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("This is App info des"),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: themeData.hintColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.only(
              left: Base.BASE_PADDING_HALF,
              right: Base.BASE_PADDING_HALF,
              top: 4,
              bottom: 4,
            ),
            child: Text(
              "WEB",
              style: TextStyle(
                fontSize: themeData.textTheme.bodySmall!.fontSize,
                color: themeData.hintColor,
              ),
            ),
          ),
        )
      ],
    );
  }
}
