import 'package:flutter/material.dart';

class LogoComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // this should be change to a logo image
      width: 40,
      height: 40,
      color: Colors.red,
      child: Icon(
        Icons.image,
        size: 40,
      ),
    );
  }
}
