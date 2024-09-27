import 'package:nowser/data/bookmark.dart';
import 'package:sqflite/sqflite.dart';

import 'db.dart';

class BookmarkDB {
  static Future<int> insert(Bookmark o, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    return await db.insert("bookmark", o.toJson());
  }

  static Future<int?> total({DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    var sql = "select count(1) from bookmark";
    return Sqflite.firstIntValue(await db.rawQuery(sql));
  }

  static Future<List<Bookmark>> all({DatabaseExecutor? db}) async {
    List<Bookmark> objs = [];
    List<Object?>? arguments = [];
    db = await DB.getDB(db);
    var sql = "select * from bookmark order by created_at desc";
    List<Map<String, dynamic>> list = await db.rawQuery(sql, arguments);
    for (var i = 0; i < list.length; i++) {
      var json = list[i];
      objs.add(Bookmark.fromJson(json));
    }
    return objs;
  }

  static Future<void> deleteByIds(List<int> ids, {DatabaseExecutor? db}) async {
    var sql = "delete from bookmark where id in(";
    for (var id in ids) {
      sql += "?,";
    }
    sql = sql.substring(0, sql.length - 1);
    sql += ")";

    db = await DB.getDB(db);
    await db.execute(sql, ids);
  }
}
