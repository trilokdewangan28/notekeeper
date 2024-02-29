
import 'package:sqflite/sqflite.dart' as sql;
import 'dart:async';

class DatabaseHelper{
  
  static String dbName='notekeeper_db.db';
  static String tableName="notekeeper_table";

  //============================================================CREATE TABLE 
  static Future createTable(sql.Database database)async{
    String sql = 'CREATE TABLE IF NOT EXISTS $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, description TEXT, createdAt TEXT, priority TEXT)';
    final result = await database.execute(sql);
    return result;
  }

  //=======================================================SHOW TABLES
  static Future<List<dynamic>> showTables(sql.Database db)async{
    List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");
    return result;
  }

  //=================================================CREATE CONNECTION AND TABLE
  static Future<sql.Database> initDb()async{
    final  mydb =  sql.openDatabase(
        '$dbName',
        version: 1,
        // onCreate:  (sql.Database database, int version)async{
        //   await createTable(database);
        // }
    );
    return mydb;
  }


  //===============================================================INSERT ITEMS
  static Future<int> addNewNotes(sql.Database db,data)async{
    //final db = await SqlHelper.db();
    final id = await db.insert('$tableName', data,conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //==========================================================FETCH THE DATA
  static Future<List<Map<String,dynamic>>> getData(sql.Database db)async{
    //final db = await SqlHelper.db();
    final result = db.query('$tableName',orderBy: 'id');
    return result;
  }

  //================================================FETCH DATA BY ID
  static Future<List<Map<String,dynamic>>> getDataById(int id,sql.Database db)async{
    //final db = await SqlHelper.db();
    final result = db.query('$tableName',where: 'id=?',whereArgs: [id],limit: 1);
    return result;
  }

  //=========================================================UPDATE THE DATA
  static Future<int> updateItem(String title, String description, int id,sql.Database db)async{
    //final db = await SqlHelper.db();
    final data = {
      "title":title,
      "description":description,
      "createdAt":DateTime.now().toString()
    };
    final result = await db.update('$tableName', data, where: 'id=?',whereArgs: [id]);
    return result;

  }

  //===================================================DELETE DATA BY ID
  static Future<int> deleteItem(int id,sql.Database db)async{
    //final db = await SqlHelper.db();
    final result = await db.delete('$tableName',where: 'id=?',whereArgs: [id]);
    return result;
  }

  //=================================================DELETE WHOLE EXISTING TABLE
  static Future<dynamic> deleteTable(String tableName,sql.Database db)async{
    final result = await db.execute('DROP TABLE IF EXISTS $tableName');
    return result;
  }

}