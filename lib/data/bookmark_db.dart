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
}
