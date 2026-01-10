import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  // 1. Singleton Pattern: Ensures only one instance exists in the app
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static Database? _db;

  // 2. Singleton Database Connection
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'verbum.db'); // Kept filename to preserve your data

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
        // Migration logic preserved for existing users
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
        conflictAlgorithm: ConflictAlgorithm.replace, // Overwrites if word exists
      );
    } catch (e) {
      // Use debugPrint for development logs, silent in release
      debugPrint("Database Save Error: $e");
    }
  }

  // === UPDATED FOR CHRONOLOGICAL ORDERING ===
  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final db = await database;
      // FIX: Changed "word ASC" to "rowid DESC"
      // rowid is a hidden auto-incrementing column in SQLite.
      // DESC ensures the highest rowid (most recently saved) is returned first.
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

  // === THE NEW METHOD ===
  // Deletes all rows from the favorites table
  Future<void> clearAllFavorites() async {
    try {
      final db = await database;
      // Passing only the table name deletes all its rows
      await db.delete('favorites');
      debugPrint("All favorites cleared.");
    } catch (e) {
      debugPrint("Database Clear All Error: $e");
    }
  }
  
  // New: Helper to close DB (good practice for app termination)
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}