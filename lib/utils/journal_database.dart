import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/journal_entry.dart';

class JournalDatabase {
  static final JournalDatabase instance = JournalDatabase._init();

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
        timestamp TEXT 
      )
    ''');
  }

  Future<void> insertEntry(JournalEntry entry) async {
    final db = await instance.database;
    await db.insert('journal_entries', entry.toMap());
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
