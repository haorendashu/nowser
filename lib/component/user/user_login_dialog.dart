import 'package:flutter/material.dart';
import 'package:nostr_sdk/client_utils/keys.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/main.dart';
import 'package:nowser/util/router_util.dart';

import '../../const/base.dart';
import '../../generated/l10n.dart';

class UserLoginDialog extends StatefulWidget {
  static Future<void> show(BuildContext context) async {
    await showDialog<String>(
        context: context,
        builder: (_context) {
          return UserLoginDialog();
        });
  }

  @override
  State<StatefulWidget> createState() {
    return _UserLoginDialog();
  }
}

class _UserLoginDialog extends State<UserLoginDialog> {
  bool obscureText = true;

  TextEditingController controller = TextEditingController();

  late S s;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    s = S.of(context);

    List<Widget> list = [];
    list.add(Container(
      margin: EdgeInsets.only(bottom: Base.BASE_PADDING * 2),
      child: Text(
        s.Login,
        style: TextStyle(
          fontSize: themeData.textTheme.bodyLarge!.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    var prefixIcon = GestureDetector(
      onTap: () {},
      child: Icon(Icons.qr_code),
    );

    var suffixIcon = GestureDetector(
      onTap: () {
        setState(() {
          obscureText = !obscureText;
        });
      },
      child: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
    );

    list.add(Container(
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "nsec / hex private key",
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    ));

    list.add(Container(
      margin: EdgeInsets.only(bottom: Base.BASE_PADDING * 2),
      width: double.infinity,
      child: FilledButton(onPressed: confirm, child: Text(s.Confirm)),
    ));

    list.add(GestureDetector(
      onTap: () {
        var pk = generatePrivateKey();
        controller.text = pk;
      },
      child: Container(
        child: Text(
          s.Generate_a_private_key,
          style: TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ));

    var main = Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );

    return Dialog(
      child: Container(
        padding: EdgeInsets.all(Base.BASE_PADDING * 2),
        child: main,
      ),
    );
  }

  void confirm() {
    var pk = controller.text;
    try {
      if (Nip19.isPrivateKey(pk)) {
        pk = Nip19.decode(pk);
      }

      var pubkey = getPublicKey(pk);
      if (StringUtil.isBlank(pubkey)) {
        keyCheckFail();
        return;
      }

      keyProvider.addKey(pk);
      RouterUtil.back(context);
    } catch (e) {
      keyCheckFail();
    }
  }

  void keyCheckFail() {}
}
