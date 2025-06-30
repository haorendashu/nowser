import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nesigner_adapter/nesigner.dart';
import 'package:nostr_sdk/client_utils/keys.dart';
import 'package:nostr_sdk/signer/local_nostr_signer.dart';
import 'package:nostr_sdk/signer/nostr_signer.dart';
import 'package:nostr_sdk/utils/string_util.dart';

class KeyProvider extends ChangeNotifier {
  static const String KEY_NAME = "nowserKeys";

  List<String> keys = [];

  List<String> pubkeys = [];

  Map<String, String> keysMap = {};

  Map<String, Nesigner> _nesignerMap = {};

  Future<void> init() async {
    await reload();
  }

  String? _getPubkeyFromKeyStr(String keyStr) {
    if (Nesigner.isNesignerKey(keyStr)) {
      return Nesigner.getPubkeyFromKey(keyStr);
    }

    return getPublicKey(keyStr);
  }

  Future<void> reload() async {
    keys.clear();
    keysMap = {};
    pubkeys = [];

    final storage = FlutterSecureStorage();
    var strs = await storage.read(key: KEY_NAME);
    if (StringUtil.isNotBlank(strs)) {
      var jsonObj = jsonDecode(strs!);
      if (jsonObj is List) {
        for (var jsonObjItem in jsonObj) {
          if (jsonObjItem is String) {
            keys.add(jsonObjItem);
            var pubkey = _getPubkeyFromKeyStr(jsonObjItem);
            if (StringUtil.isNotBlank(pubkey)) {
              keysMap[pubkey!] = jsonObjItem;
              pubkeys.add(pubkey);
            }
          }
        }
      }
    }
  }

  void _regenMemKeys() {
    keys = [...keys];

    keysMap = {};
    pubkeys = [];

    for (var key in keys) {
      var pubkey = _getPubkeyFromKeyStr(key);
      if (StringUtil.isNotBlank(pubkey)) {
        keysMap[pubkey!] = key;
        pubkeys.add(pubkey);
      }
    }
  }

  void setDefault(String pubkey) {
    var key = keysMap[pubkey];
    if (StringUtil.isNotBlank(key)) {
      keys.remove(key);

      List<String> newKeys = [key!];
      newKeys.addAll(keys);

      keys = newKeys;
      _saveKey();
      _regenMemKeys();
      notifyListeners();
    }
  }

  Future<void> _saveKey() async {
    var jsonStr = jsonEncode(keys);
    final storage = FlutterSecureStorage();
    await storage.write(key: KEY_NAME, value: jsonStr);
  }

  void addKey(String keyStr) {
    if (exist(keyStr)) {
      return;
    }

    var pubkey = _getPubkeyFromKeyStr(keyStr);
    if (StringUtil.isBlank(pubkey)) {
      return;
    }

    keys.add(keyStr);
    keysMap[pubkey!] = keyStr;
    pubkeys.add(pubkey);

    _saveKey();
    _regenMemKeys();
    notifyListeners();
  }

  void removeKey(String pubkey) {
    var keyStr = keysMap.remove(pubkey);
    if (StringUtil.isNotBlank(keyStr)) {
      keys.remove(keyStr);
    }
    pubkeys.remove(pubkey);

    _saveKey();
    _regenMemKeys();
    notifyListeners();
  }

  bool exist(String privateKey) {
    return keys.contains(privateKey);
  }

  Future<NostrSigner?> getSigner(String pubkey) async {
    var nesigner = _nesignerMap[pubkey];
    if (nesigner != null) {
      return nesigner;
    }

    var key = keysMap[pubkey];
    if (StringUtil.isNotBlank(key)) {
      if (Nesigner.isNesignerKey(key!)) {
        var pinCode = Nesigner.getPinCodeFromKey(key);
        if (StringUtil.isBlank(pinCode)) {
          return null;
        }

        nesigner = Nesigner(pinCode, pubkey: pubkey);
        await nesigner.start();
        _nesignerMap[pubkey] = nesigner;
        return nesigner;
      }

      return LocalNostrSigner(key);
    }

    return null;
  }
}
