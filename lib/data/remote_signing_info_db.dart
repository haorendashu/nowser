import 'package:nowser/data/remote_signing_info.dart';

import 'package:sqflite/sqflite.dart';
import 'package:nostr_sdk/utils/encrypt_util.dart';
import 'db.dart';

class RemoteSigningInfoDB {
  static Future<Map<String, dynamic>> _toJsonWithEncrypt(
      RemoteSigningInfo o, String encryptKey) async {
    var iv = "${o.updatedAt}000000";
    var json = o.toJson();
    json["secret"] =
        await EncryptUtil.aesEncrypt(json["secret"]!, encryptKey, iv);
    return json;
  }

  static Future<RemoteSigningInfo> _fromJsonWithDecrypt(
      Map<String, dynamic> json, String encryptKey) async {
    var iv = "${json["updated_at"]}000000";
    var signingInfo = RemoteSigningInfo.fromJson(json);
    signingInfo.secret =
        await EncryptUtil.aesDecrypt(json["secret"]!, encryptKey, iv);
    return signingInfo;
  }

  static Future<int> insert(RemoteSigningInfo o, String encryptKey,
      {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    return await db.insert(
        "remote_signing_info", await _toJsonWithEncrypt(o, encryptKey));
  }

  static Future<RemoteSigningInfo?> getByAppId(int appId, String encryptKey,
      {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    List<Map<String, dynamic>> list = await db.rawQuery(
        "select * from remote_signing_info where app_id = ?", [appId]);
    if (list.isNotEmpty) {
      return await _fromJsonWithDecrypt(list.first, encryptKey);
    }

    return null;
  }

  static Future<List<RemoteSigningInfo>> penddingRemoteSigningInfo(
      String encryptKey,
      {DatabaseExecutor? db}) async {
    List<RemoteSigningInfo> objs = [];

    var since =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - 60 * 60 * 24 * 3;

    db = await DB.getDB(db);
    List<Map<String, dynamic>> list = await db.rawQuery(
        "select * from remote_signing_info where app_id is null and created_at > ?",
        [since]);
    for (var i = 0; i < list.length; i++) {
      var json = list[i];
      try {
        objs.add(await _fromJsonWithDecrypt(json, encryptKey));
      } catch (e) {
        print("RemoteSigningInfoDB penddingRemoteSigningInfo error: $e");
      }
    }

    return objs;
  }

  static Future<int> update(RemoteSigningInfo o, String encryptKey,
      {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    return await db.update(
        "remote_signing_info", await _toJsonWithEncrypt(o, encryptKey),
        where: "id = ?", whereArgs: [o.id]);
  }

  static Future<void> deleteByAppId(int appId, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    db.execute("delete from remote_signing_info where app_id = ?", [appId]);
  }
}
