import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tinder/data/profiles.dart';

enum ContactState{
  yettoswipe,
  liked,
  disliked,
  superliked
}

class DatabaseHelper {

  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'contacts';

  static final columnId = '_id';
  static final columnName = 'name';
  static final columnphones = 'phones';
  static final columnemails = 'emails';
  static final columnState='state';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId TEXT PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnphones TEXT NOT NULL,
            $columnemails TEXT NOT NULL,
            $columnState INTEGER NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  static Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    row[columnState]=ContactState.yettoswipe.index;
    return await db.insert(table, row);
  }

  static Future<int> insertAll(List<Map<String, dynamic>> rows) async {
    Database db = await instance.database;
    Batch batch=db.batch();
    for(Map<String,dynamic> row in rows){
      row[columnState]=ContactState.yettoswipe.index;
      batch.insert(table, row);
    }

    await batch.commit();
  }

  static Future<int> insertAllProfiles(Iterable<Profile> profiles) async {
    Database db = await instance.database;
    Batch batch=db.batch();
    for(Profile profile in profiles){
      Map map = profile.toMap();
      map[columnState]=ContactState.yettoswipe.index;
      batch.insert(table, map);
    }
    await batch.commit();
  }

  static Future<int> updateAllProfiles(Iterable<Profile> rows) async {
    Database db = await instance.database;
    Batch batch=db.batch();
    rows.forEach((row)=>batch.update(table, row.toMap(), where: '$columnId = ?', whereArgs: [row.id]));
    await batch.commit();
  }

  static Future<int> deleteAllProfiles(Iterable<Profile> rows) async {
    Database db = await instance.database;
    Batch batch=db.batch();
    rows.forEach((row)=>batch.delete(table, where: '$columnId = ?', whereArgs: [row.id]));
    await batch.commit();
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  static Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  static Future<List<Map<String, dynamic>>> queryYetToSwiped() async {
    return queryContactState(ContactState.yettoswipe);
  }

  static Future<List<Map<String, dynamic>>> queryLiked() async {
    return queryContactState(ContactState.liked);
  }

  static Future<List<Map<String, dynamic>>> queryDisliked() async {
    return queryContactState(ContactState.disliked);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  static Future<List<Map<String, dynamic>>> queryContactState(ContactState contactState) async {
    Database db = await instance.database;
    return await db.query(table,where: '$columnState = ?', whereArgs: [contactState.index]);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  static Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  static Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<int> updateLiked(String contactId) async {
    return updateContactState(contactId, ContactState.liked);
  }

  static Future<int> updateDisliked(String contactId) async {

    return updateContactState(contactId, ContactState.disliked);
  }

  static Future<int> updateSuperliked(String contactId) async {

    return updateContactState(contactId, ContactState.superliked);
  }

  static Future<int> updateContactState(String contactId,ContactState contactState) async {
    Database db = await instance.database;
    var row = Map<String,dynamic>();
    row[columnId]=contactId;
    row[columnState]=contactState.index;
    String id = row[columnId];

    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }



  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  static Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}