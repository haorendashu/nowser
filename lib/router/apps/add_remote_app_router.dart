import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_sdk/client_utils/keys.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/nip46/nostr_remote_signer_info.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/qrscanner.dart';
import 'package:nowser/data/remote_signing_info.dart';
import 'package:nowser/data/remote_signing_info_db.dart';
import 'package:nowser/main.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../const/base.dart';
import '../../provider/key_provider.dart';

class AddRemoteAppRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddRemoteAppRouter();
  }
}

class _AddRemoteAppRouter extends State<AddRemoteAppRouter> {
  TextEditingController nostrconnectConn = TextEditingController();

  TextEditingController bunkerConn = TextEditingController();

  bool editBunker = false;

  @override
  void initState() {
    super.initState();

    relayAddrController.addListener(() {
      reloadBunker();
    });
    secretController.addListener(() {
      reloadBunker();
    });
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var textColor = themeData.textTheme.bodyMedium!.color;
    var mainColor = themeData.primaryColor;

    if (StringUtil.isBlank(bunkerConn.text)) {
      refreshBunkerUrl();
    }

    Widget bunkerShowmoreBtn = Container(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          setState(() {
            editBunker = true;
          });
        },
        behavior: HitTestBehavior.translucent,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.expand_more),
            Text("Edit"),
          ],
        ),
      ),
    );
    if (editBunker) {
      bunkerShowmoreBtn = Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            setState(() {
              editBunker = false;
            });
          },
          behavior: HitTestBehavior.translucent,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.expand_less),
              Text("Close Edit"),
            ],
          ),
        ),
      );
    }

    Widget bunkerWidget = Container();
    if (editBunker) {
      bunkerWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: TextField(
              decoration: InputDecoration(
                labelText: "Relay",
              ),
              controller: relayAddrController,
            ),
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(
                labelText: "Secret",
              ),
              controller: secretController,
            ),
          ),
        ],
      );
    }

    var main = DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 60,
            child: TabBar(
              labelColor: textColor,
              unselectedLabelColor: textColor,
              indicatorColor: mainColor,
              tabs: [
                Text(
                  "Connect by\nnostrconnect:// url",
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Connect by\nbunker:// url",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
              child: Container(
            child: TabBarView(
              children: [
                Container(
                  padding: EdgeInsets.all(Base.BASE_PADDING),
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: Base.BASE_PADDING_HALF),
                        child: TextField(
                          controller: nostrconnectConn,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: Base.BASE_PADDING_HALF),
                        child: Row(
                          children: [
                            Expanded(child: Container()),
                            IconButton(
                              onPressed: () {
                                scanNostrConnectQRCode();
                              },
                              icon: Icon(Icons.qr_code_scanner),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: Base.BASE_PADDING),
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {},
                          child: Text("Confirm"),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(Base.BASE_PADDING),
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: Base.BASE_PADDING_HALF),
                        child: TextField(
                          controller: bunkerConn,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          maxLines: 4,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: Base.BASE_PADDING_HALF),
                        child: Row(
                          children: [
                            Expanded(child: Container()),
                            IconButton(
                                onPressed: refreshBunkerUrl,
                                icon: Icon(Icons.refresh)),
                            // IconButton(
                            //     onPressed: showBunkerUrlQRCode,
                            //     icon: Icon(Icons.qr_code)),
                            IconButton(
                                onPressed: copyBunkerUrl,
                                icon: Icon(Icons.copy)),
                          ],
                        ),
                      ),
                      bunkerShowmoreBtn,
                      bunkerWidget,
                      Container(
                        margin: EdgeInsets.only(top: Base.BASE_PADDING),
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: confirmBunkerUrl,
                          child: Text("Confirm"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackBtnComponent(),
        title: Text(
          "Add Remote App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: themeData.textTheme.bodyLarge!.fontSize,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(Base.BASE_PADDING),
        child: main,
      ),
    );
  }

  Future<void> scanNostrConnectQRCode() async {
    var value = await QRScanner.show(context);
    if (StringUtil.isNotBlank(value)) {
      nostrconnectConn.text = value;
    }
  }

  void confirmNostrConnect() {
    var remoteSigningInfo =
        RemoteSigningInfo.parseNostrConnectUrl(nostrconnectConn.text);
    if (remoteSigningInfo == null) {
      // TODO
      return;
    }

    remoteSigningInfo.remoteSignerKey = generatePrivateKey();
    remoteSigningInfo.createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    remoteSigningInfo.updatedAt = remoteSigningInfo.createdAt;

    // TODO
  }

  TextEditingController remoteSignerKeyController = TextEditingController();

  TextEditingController relayAddrController = TextEditingController();

  TextEditingController secretController = TextEditingController();

  void refreshBunkerUrl() {
    remoteSignerKeyController.text = generatePrivateKey();
    secretController.text = StringUtil.rndNameStr(20);
    relayAddrController.text = "wss://relay.nsec.app";

    reloadBunker();
  }

  // void showBunkerUrlQRCode() {}

  void copyBunkerUrl() {
    Clipboard.setData(ClipboardData(text: bunkerConn.text)).then((_) {
      // TODO
      // BotToast.showText(text: S.of(context).Copy_success);
    });
  }

  void confirmBunkerUrl() {
    var remoteSignerKey = remoteSignerKeyController.text;
    var relays = [relayAddrController.text];

    var remoteSigningInfo = RemoteSigningInfo(
      remoteSignerKey: remoteSignerKey,
      relays: relays.join(","),
      secret: secretController.text,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    remoteSigningInfo.updatedAt = remoteSigningInfo.createdAt;

    remoteSigningProvider.addRemoteSigningInfo(remoteSigningInfo);
    RouterUtil.back(context);
  }

  void reloadBunker() {
    var remoteSignerKey = remoteSignerKeyController.text;
    var remoteSignerPubkey = getPublicKey(remoteSignerKey);

    var nostrRemoteSignerInfo = NostrRemoteSignerInfo(
      remoteUserPubkey: remoteSignerPubkey,
      relays: [relayAddrController.text],
      optionalSecret: secretController.text,
    );
    bunkerConn.text = nostrRemoteSignerInfo.toString();
  }
}
