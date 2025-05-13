import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/journal_entry.dart';

class JournalDatabase {
  static final JournalDatabase instance = JournalDatabase._init();

  static const String table = "journal_entries";

  static Database? _database;
  JournalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('psychinsightpro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_text TEXT,
        score INTEGER,
        reasoning TEXT,
        confidence TEXT,
        isNeglect INTEGER DEFAULT 0,
        isRepair INTEGER DEFAULT 0,
        isShared INTEGER DEFAULT 0,
        isBid INTEGER DEFAULT 0,
        timestamp TEXT 
      )
    ''');
  }

  Future<void> insertEntry(JournalEntry entry) async {
    final db = await instance.database;
    await db.insert('journal_entries', entry.toMap());
  }

  Future<int> updateEntry(JournalEntry currentEntry) async {
    if (kDebugMode) {
      print("Updating entry with ID: ${currentEntry.id}");
    }
    final db = await database;
    return await db.update(
      'journal_entries',
      currentEntry.toMap(),
      where: 'id = ?',
      whereArgs: [currentEntry.id],
    );
  }

  Future<int> updateEntry0(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      table,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
