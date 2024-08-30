import 'dart:io';

import 'package:nostr_sdk/utils/platform_util.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';

class DB {
  static const _VERSION = 1;

  static const _dbName = "nowser.db";

  static Database? _database;

  static init() async {
    String path = _dbName;

    if (!PlatformUtil.isWeb()) {
      var databasesPath = await getDatabasesPath();
      path = join(databasesPath, _dbName);
    }

    try {
      _database =
          await openDatabase(path, version: _VERSION, onCreate: _onCreate);
    } catch (e) {
      if (Platform.isLinux) {
        // maybe it need install sqlite first, but this command need run by root.
        await run('sudo apt-get -y install libsqlite3-0 libsqlite3-dev');
        _database =
            await openDatabase(path, version: _VERSION, onCreate: _onCreate);
      }
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    // init db
    db.execute(
        "create table app(id          integer not null constraint app_pk primary key autoincrement,pubkey        text    not null,app_type    integer not null,code        text    not null,name        text    not null,image       text,permissions text);");
    db.execute(
        "create table auth_log(id          integer not null constraint auth_log_pk primary key autoincrement,app_id      integer not null,auth_type   integer not null,event_kind  integer,title       text,content     text,auth_result integer not null,created_at  integer not null);");
    db.execute("create index auth_log_index on auth_log (app_id);");
  }

  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  static Future<DatabaseExecutor> getDB(DatabaseExecutor? db) async {
    if (db != null) {
      return db;
    }
    return getCurrentDatabase();
  }

  static void close() {
    _database?.close();
    _database = null;
  }
}