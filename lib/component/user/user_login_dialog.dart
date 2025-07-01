import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_sdk/client_utils/keys.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/utils/platform_util.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/main.dart';
import 'package:nowser/util/router_util.dart';
import 'package:nesigner_adapter/nesigner_adapter.dart';
import 'package:hex/hex.dart';

import '../../const/base.dart';
import '../../generated/l10n.dart';
import '../cust_state.dart';
import 'nesigner_login_dialog.dart';

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

class _UserLoginDialog extends CustState<UserLoginDialog> {
  bool obscureText = true;

  TextEditingController controller = TextEditingController();

  late S s;

  bool existNesigner = false;

  @override
  Future<void> onReady(BuildContext context) async {
    if (PlatformUtil.isPC() || PlatformUtil.isAndroid()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkNesigner();
      });
    }
  }

  Future<void> checkNesigner() async {
    try {
      var exist = await NesignerUtil.checkNesignerExist();
      if (exist != existNesigner) {
        setState(() {
          existNesigner = exist;
        });
      }
    } catch (e) {
      print("checkNesigner error $e");
    }
  }

  @override
  Widget doBuild(BuildContext context) {
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

    if (existNesigner) {
      list.add(Container(
        child: Text(s.or),
      ));

      list.add(GestureDetector(
        onTap: loginWithNesigner,
        child: Container(
          child: Text(
            s.Login_with_Nesigner,
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ));
    }

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

  Future<void> loginWithNesigner() async {
    var nesignerInputStr = await NesignerLoginDialog.show(context);
    if (nesignerInputStr == null) {
      return;
    }

    var strs = nesignerInputStr.split(":");
    var pinCode = strs[0];

    var cancelFunc = BotToast.showLoading();

    var nesigner = Nesigner(pinCode);
    try {
      if (!(await nesigner.start())) {
        BotToast.showText(text: "Connect to nesigner fail.");
        return;
      }

      if (strs.length > 1) {
        var privateKey = strs[1];
        var updateResult = await nesigner.updateKey(pinCode, privateKey);
        print("update result $updateResult");
      }

      var pubkey = await nesigner.getPublicKey();
      if (StringUtil.isBlank(pubkey)) {
        try {
          // login fail, should close the signer.
          nesigner.close();
        } catch (e) {
          print("getPublicKey error $e");
        }
        BotToast.showText(text: s.Login_fail);
        return;
      }

      var keyStr = Nesigner.genKey(pinCode, pubkey: pubkey);
      keyProvider.addKey(keyStr);
    } finally {
      try {
        nesigner.close();
      } catch (e) {}
      cancelFunc.call();
    }

    RouterUtil.back(context);
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
