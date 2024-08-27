import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nostr_sdk/client_utils/keys.dart';
import 'package:nostr_sdk/utils/string_util.dart';

class KeyProvider extends ChangeNotifier {
  static const String KEY_NAME = "nowserKeys";

  List<String> keys = [];

  List<String> pubkeys = [];

  Map<String, String> keysMap = {};

  Future<void> init() async {
    await reload();
  }

  Future<void> reload() async {
    keys.clear();
    pubkeys.clear();
    keysMap.clear();

    final storage = FlutterSecureStorage();
    var strs = await storage.read(key: KEY_NAME);
    if (StringUtil.isNotBlank(strs)) {
      var jsonObj = jsonDecode(strs!);
      if (jsonObj is List) {
        for (var jsonObjItem in jsonObj) {
          if (jsonObjItem is String) {
            keys.add(jsonObjItem);
            var pubkey = getPublicKey(jsonObjItem);
            keysMap[pubkey] = jsonObjItem;
            pubkeys.add(pubkey);
          }
        }
      }
    }
  }

  Future<void> _saveKey() async {
    var jsonStr = jsonEncode(keys);
    final storage = FlutterSecureStorage();
    await storage.write(key: KEY_NAME, value: jsonStr);
  }

  void addKey(String privateKey) {
    if (exist(privateKey)) {
      return;
    }

    keys.add(privateKey);
    var pubkey = getPublicKey(privateKey);
    keysMap[pubkey] = privateKey;
    pubkeys.add(pubkey);

    _saveKey();
    notifyListeners();
  }

  void removeKey(String pubkey) {
    var privateKey = keysMap.remove(pubkey);
    if (StringUtil.isNotBlank(privateKey)) {
      keys.remove(privateKey);
      pubkeys.remove(pubkey);
    }

    _saveKey();
    notifyListeners();
  }

  bool exist(String privateKey) {
    return keys.contains(privateKey);
  }
}
