import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

class DatabaseHelper {
  DatabaseHelper._();

  // Tests use a separate database without touching the user's notes.
  DatabaseHelper.forTesting(Database database)
    : _database = Future.value(database);

  static final DatabaseHelper instance = DatabaseHelper._();
  Future<Database>? _database;

  Future<Database> get database => _database ??= _openDatabase();

  Future<Database> _openDatabase() async {
    try {
      final directory = await getDatabasesPath();
      return await openDatabase(
        p.join(directory, 'notes.db'),
        version: 2,
        onCreate: (db, version) => createTables(db),
        onUpgrade: onUpgrade,
      );
    } catch (_) {
      _database = null;
      rethrow;
    }
  }

  static Future<void> createTables(Database db) => db.execute('''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at TEXT NOT NULL,
      category TEXT NOT NULL DEFAULT 'Umum'
    )
  ''');

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE notes ADD COLUMN created_at TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        "ALTER TABLE notes ADD COLUMN category TEXT NOT NULL DEFAULT 'Umum'",
      );
    }
  }

  Future<int> insert(Note note) async {
    final db = await database;
    return db.insert('notes', note.toMap());
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final rows = await db.query('notes', orderBy: 'id DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<List<Note>> searchNotes(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return getAllNotes();
    final db = await database;
    final rows = await db.query(
      'notes',
      where: 'title LIKE ?',
      whereArgs: ['%$clean%'],
      orderBy: 'id DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  Future<int> update(Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final pending = _database;
    if (pending == null) return;
    final db = await pending;
    await db.close();
    _database = null;
  }
}
