import 'package:flutter/material.dart';
import 'package:nowser/const/base.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class SimpleQrcodeDialog extends StatefulWidget {
  String data;

  SimpleQrcodeDialog(this.data);

  static Future<void> show(BuildContext context, String date) async {
    return await showDialog<void>(
        context: context,
        builder: (_context) {
          return SimpleQrcodeDialog(date);
        });
  }

  @override
  State<StatefulWidget> createState() {
    return _SimpleQrcodeDialog();
  }
}

class _SimpleQrcodeDialog extends State<SimpleQrcodeDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(Base.BASE_PADDING * 2),
        child: PrettyQrView.data(
          data: widget.data,
          // decoration: const PrettyQrDecoration(
          //   image: PrettyQrDecorationImage(
          //     image: AssetImage('images/flutter.png'),
          //   ),
          // ),
        ),
      ),
    );
  }
}
