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
        "create table app(id            integer not null constraint app_pk primary key autoincrement,pubkey        text    not null,app_type      integer not null,code          text    not null,name          text,image         text,connect_type  integer not null,always_allow  text,always_reject text,created_at    integer not null,updated_at    integer not null);");

    db.execute(
        "create table auth_log(id          integer not null constraint auth_log_pk primary key autoincrement,app_id      integer not null,auth_type   integer not null,event_kind  integer,title       text,content     text,auth_result integer not null,created_at  integer not null);");
    db.execute("create index auth_log_index on auth_log (app_id);");

    db.execute(
        "create table remote_signing_info(id                integer not null constraint remote_signing_info_pk primary key autoincrement,app_id            integer,local_pubkey      text,remote_signer_key text,relays            text,secret            text,created_at        integer,updated_at        integer);");

    db.execute(
        "create table zap_log(id         integer not null constraint zap_log_pk primary key autoincrement,app_id     integer not null constraint zap_log_index unique,zap_type   integer not null,num        integer not null,created_at integer not null);");
    db.execute("create index zap_log_index on zap_log (app_id);");
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
