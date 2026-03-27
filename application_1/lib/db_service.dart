import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'verbum.db'); 

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            word TEXT PRIMARY KEY, 
            meaning TEXT, 
            pronunciation TEXT, 
            example TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE favorites ADD COLUMN example TEXT');
        }
      },
    );
  }

  Future<void> saveFavorite(Map<String, dynamic> word) async {
    try {
      final db = await database;
      await db.insert(
        'favorites',
        {
          'word': word['word'],
          'meaning': word['meaning'],
          'pronunciation': word['pronunciation'] ?? '',
          'example': word['example'] ?? '',
        },
        conflictAlgorithm: ConflictAlgorithm.replace, 
      );
    } catch (e) {
      debugPrint("Database Save Error: $e");
    }
  }
  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final db = await database;
      return await db.query('favorites', orderBy: "rowid DESC"); 
    } catch (e) {
      debugPrint("Database Fetch Error: $e");
      return [];
    }
  }

  Future<void> deleteFavorite(String word) async {
    try {
      final db = await database;
      await db.delete('favorites', where: 'word = ?', whereArgs: [word]);
    } catch (e) {
      debugPrint("Database Delete Error: $e");
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      final db = await database;
      await db.delete('favorites');
      debugPrint("All favorites cleared.");
    } catch (e) {
      debugPrint("Database Clear All Error: $e");
    }
  }
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
