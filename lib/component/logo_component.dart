import 'package:flutter/material.dart';

class LogoComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // this should be change to a logo image
      width: 40,
      height: 40,
      child: const Image(
        image: AssetImage(
          "assets/imgs/logo/logo512.png",
        ),
        width: 40,
        height: 40,
      ),
    );
  }
}
