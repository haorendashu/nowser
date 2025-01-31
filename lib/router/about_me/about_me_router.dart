import 'package:flutter/material.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/util/router_util.dart';

import '../../generated/l10n.dart';

class AboutMeRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutMeRouter();
  }
}

class _AboutMeRouter extends State<AboutMeRouter> {
  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    var themeData = Theme.of(context);
    var paddingTop = MediaQuery.of(context).padding.top;

    List<Widget> list = [];

    list.add(Container(
      margin: EdgeInsets.only(top: 100),
      child: Image.asset(
        "assets/imgs/logo/logo512.png",
        width: 100,
        height: 100,
      ),
    ));

    list.add(Container(
      margin: EdgeInsets.only(top: 40),
      child: Text(
        "Nowser",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: themeData.textTheme.bodyLarge!.fontSize,
        ),
      ),
    ));

    list.add(Container(
      margin: EdgeInsets.only(top: 10),
      child: Text(
        "V ${Base.VERSION_NAME}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: themeData.textTheme.bodySmall!.fontSize,
        ),
      ),
    ));

    list.add(Expanded(child: Container()));

    list.add(Container(
      margin: EdgeInsets.only(bottom: 50),
      // child: Text(
      //   s.Privacy,
      //   style: TextStyle(
      //     fontSize: themeData.textTheme.bodySmall!.fontSize,
      //   ),
      // ),
    ));

    var backBtn = GestureDetector(
      onTap: () {
        RouterUtil.back(context);
      },
      behavior: HitTestBehavior.translucent,
      child: Icon(Icons.chevron_left),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: list,
              ),
            ),
            Positioned(
              top: paddingTop + Base.BASE_PADDING,
              left: Base.BASE_PADDING,
              child: backBtn,
            ),
          ],
        ),
      ),
    );
  }
}
