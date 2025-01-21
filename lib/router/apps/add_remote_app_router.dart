import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_sdk/client_utils/keys.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/nip46/nostr_remote_signer_info.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/cust_state.dart';
import 'package:nowser/component/qrscanner.dart';
import 'package:nowser/component/simple_qrcode_dialog.dart';
import 'package:nowser/data/remote_signing_info.dart';
import 'package:nowser/data/remote_signing_info_db.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/build_in_relay_provider.dart';
import 'package:nowser/util/ip_util.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../const/base.dart';
import '../../generated/l10n.dart';
import '../../provider/key_provider.dart';

class AddRemoteAppRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddRemoteAppRouter();
  }
}

class _AddRemoteAppRouter extends CustState<AddRemoteAppRouter> {
  TextEditingController nostrconnectConn = TextEditingController();

  TextEditingController bunkerConn = TextEditingController();

  bool editBunker = false;

  bool localRelay = false;

  String? pubkey;

  String? localIp;

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
  Future<void> onReady(BuildContext context) async {
    localIp = await IpUtil.getIp();
  }

  late S s;

  @override
  Widget doBuild(BuildContext context) {
    s = S.of(context);
    var themeData = Theme.of(context);
    var textColor = themeData.textTheme.bodyMedium!.color;
    var mainColor = themeData.primaryColor;

    var keyWidget =
        Selector<KeyProvider, List<String>>(builder: (context, pubkeys, child) {
      List<DropdownMenuItem<String>> items = [];
      for (var pubkey in pubkeys) {
        items.add(DropdownMenuItem(
          value: pubkey,
          child: Text(
            Nip19.encodePubKey(pubkey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ));
      }

      if (StringUtil.isBlank(pubkey) && pubkeys.isNotEmpty) {
        pubkey = pubkeys.first;
        refreshBunkerUrl();
      }

      return DropdownButton<String>(
        items: items,
        isExpanded: true,
        onChanged: (String? value) {
          if (StringUtil.isNotBlank(value)) {
            pubkey = value;
            refreshBunkerUrl();
            setState(() {});
          }
        },
        value: pubkey,
      );
    }, selector: (context, provider) {
      return provider.pubkeys;
    });

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.expand_more),
            Text(s.Edit),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.expand_less),
              Text(s.Close_Edit),
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
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    right: Base.BASE_PADDING_HALF,
                  ),
                  child: Text("${s.Local_Relay}:"),
                ),
                Checkbox(
                  value: localRelay,
                  onChanged: onLocalRelayChange,
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(
                labelText: s.Relay,
                enabled: !localRelay,
              ),
              controller: relayAddrController,
            ),
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(
                labelText: s.Secret,
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
            child: keyWidget,
          ),
          Container(
            height: 60,
            child: TabBar(
              labelColor: textColor,
              unselectedLabelColor: textColor,
              indicatorColor: mainColor,
              tabs: [
                GestureDetector(
                  child: Text(
                    "${s.Connect_by}\nnostrconnect:// url",
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    BotToast.showText(text: s.Comming_soon);
                  },
                ),
                Text(
                  "${s.Connect_by}\nbunker:// url",
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
                  padding: const EdgeInsets.all(Base.BASE_PADDING),
                  child: ListView(
                    children: [
                      Container(
                        margin:
                            const EdgeInsets.only(top: Base.BASE_PADDING_HALF),
                        child: TextField(
                          controller: nostrconnectConn,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(top: Base.BASE_PADDING_HALF),
                        child: Row(
                          children: [
                            Expanded(child: Container()),
                            IconButton(
                              onPressed: () {
                                scanNostrConnectQRCode();
                              },
                              icon: const Icon(Icons.qr_code_scanner),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: Base.BASE_PADDING),
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            BotToast.showText(text: s.Comming_soon);
                          },
                          child: Text(s.Confirm),
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
                            IconButton(
                                onPressed: showBunkerUrlQRCode,
                                icon: Icon(Icons.qr_code)),
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
                          child: Text(s.Confirm),
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
          s.Add_Remote_App,
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
      nostrconnectConn.text = value!;
    }
  }

  String remoteSignerKey = generatePrivateKey();

  void confirmNostrConnect() {
    var remoteSigningInfo =
        RemoteSigningInfo.parseNostrConnectUrl(nostrconnectConn.text);
    if (remoteSigningInfo == null) {
      // TODO
      return;
    }

    remoteSigningInfo.remoteSignerKey = remoteSignerKey;
    remoteSigningInfo.createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    remoteSigningInfo.updatedAt = remoteSigningInfo.createdAt;

    // TODO
  }

  TextEditingController relayAddrController = TextEditingController();

  static const String DEFAULT_RELAY = "wss://relay.nsec.app";

  TextEditingController secretController = TextEditingController();

  void refreshBunkerUrl() {
    remoteSignerKey = generatePrivateKey();
    secretController.text = StringUtil.rndNameStr(20);
    if (StringUtil.isBlank(localIp) ||
        !relayAddrController.text.contains(localIp!)) {
      relayAddrController.text = DEFAULT_RELAY;
    }

    reloadBunker();
  }

  void showBunkerUrlQRCode() {
    reloadBunker();
    SimpleQrcodeDialog.show(context, bunkerConn.text);
  }

  void copyBunkerUrl() {
    Clipboard.setData(ClipboardData(text: bunkerConn.text)).then((_) {
      BotToast.showText(text: S.of(context).Copy_success);
    });
  }

  void confirmBunkerUrl() {
    if (StringUtil.isBlank(pubkey)) {
      return;
    }

    List<String> relays = [];
    if (localRelay) {
      relays.add("ws://127.0.0.1:${BuildInRelayProvider.port}");
    } else {
      relays.add(relayAddrController.text);
    }

    var remoteSigningInfo = RemoteSigningInfo(
      remotePubkey: pubkey,
      remoteSignerKey: remoteSignerKey,
      relays: relays.join(","),
      secret: secretController.text,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    remoteSigningInfo.updatedAt = remoteSigningInfo.createdAt;

    remoteSigningProvider.saveRemoteSigningInfo(remoteSigningInfo);
    RouterUtil.back(context);
  }

  void reloadBunker() {
    var nostrRemoteSignerInfo = NostrRemoteSignerInfo(
      remoteSignerPubkey: getPublicKey(remoteSignerKey),
      relays: [relayAddrController.text],
      optionalSecret: secretController.text,
    );
    bunkerConn.text = nostrRemoteSignerInfo.toString();
  }

  void onLocalRelayChange(bool? v) {
    if (v == true) {
      relayAddrController.text = "ws://${localIp}:${BuildInRelayProvider.port}";
    } else if (v == false) {
      relayAddrController.text = DEFAULT_RELAY;
    }

    if (v != null) {
      setState(() {
        localRelay = v;
      });
      reloadBunker();
    }
  }
}
