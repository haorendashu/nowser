import 'package:nowser/data/db.dart';

import 'package:sqflite/sqflite.dart';

import 'app.dart';

class AppDB {
  static Future<List<App>> all() async {
    List<App> objs = [];
    var db = await DB.getCurrentDatabase();
    List<Map<String, dynamic>> list =
        await db.rawQuery("select * from app order by updated_at desc");
    for (var i = 0; i < list.length; i++) {
      var json = list[i];
      objs.add(App.fromJson(json));
    }
    return objs;
  }

  static Future<App?> get(int id, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    var list = await db.query("app", where: "id = ?", whereArgs: [id]);
    if (list.isNotEmpty) {
      return App.fromJson(list[0]);
    }
  }

  static Future<int> insert(App o, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    return await db.insert("app", o.toJson());
  }

  static Future update(App o, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    await db.update("app", o.toJson(), where: "id = ?", whereArgs: [o.pubkey]);
  }

  static Future<void> delete(int id, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    db.execute("delete from app where id = ?");
  }
}
