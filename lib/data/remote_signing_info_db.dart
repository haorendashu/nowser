import 'package:nowser/data/remote_signing_info.dart';

import 'package:sqflite/sqflite.dart';
import 'db.dart';

class RemoteSigningInfoDB {
  static Future<int> insert(RemoteSigningInfo o, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    return await db.insert("remote_signing_info", o.toJson());
  }

  static Future<RemoteSigningInfo?> getByAppId(int appId,
      {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    List<Map<String, dynamic>> list = await db.rawQuery(
        "select * from remote_signing_info where app_id = ?", [appId]);
    if (list.isNotEmpty) {
      return RemoteSigningInfo.fromJson(list.first);
    }

    return null;
  }
}
