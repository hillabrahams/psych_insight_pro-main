import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  static const String _dbName = "psychinsightpro.db";
  static const int _dbVersion = 1;
  static const String table = "journal_entries";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_text TEXT NOT NULL,
        score INTEGER NOT NULL,
        reasoning TEXT NOT NULL,
        confidence TEXT NOT NULL,
        isNeglect INTEGER NOT NULL DEFAULT 0,
        isRepair INTEGER NOT NULL DEFAULT 0,
        timestamp TEXT NULL 
    ''');
  }

  Future<int> insertEntry(JournalEntry entry) async {
    final db = await database;
    try {
      final map = entry.toMap();
      final now = DateTime.now();
      final formattedTimestamp =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      map['timestamp'] = formattedTimestamp;

      return await db.insert(table, map);
    } catch (e) {
      if (kDebugMode) print('Insert error: $e');
      return -1;
    }
  }

  Future<List<JournalEntry>> getEntriesBetweenDates(
    String start,
    String end,
  ) async {
    final db = await database;
    try {
      final result = await db.query(
        table,
        where: 'timestamp BETWEEN ? AND ?',
        whereArgs: [start, end],
        orderBy: 'timestamp ASC',
      );
      return result.map((e) => JournalEntry.fromMap(e)).toList();
    } catch (e) {
      if (kDebugMode) print('Query error: $e');
      return [];
    }
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      table,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<List<JournalEntry>> getNeglectEntriesBetweenDates(
    String start,
    String end,
  ) async {
    final db = await database;
    try {
      final result = await db.query(
        table,
        where: 'timestamp BETWEEN ? AND ? AND isNeglect = 1',
        whereArgs: [start, end],
        orderBy: 'timestamp ASC',
      );
      return result.map((e) => JournalEntry.fromMap(e)).toList();
    } catch (e) {
      if (kDebugMode) print('Neglect query error: $e');
      return [];
    }
  }
}
