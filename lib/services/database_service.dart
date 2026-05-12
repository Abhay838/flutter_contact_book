import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  static const String _tableName = 'contacts';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts_app.db');

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT DEFAULT '',
        address TEXT,
        company TEXT,
        notes TEXT,
        avatarPath TEXT,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  /// CRUD Operations

  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'name COLLATE NOCASE ASC');
    return maps.map((m) => Contact.fromMap(m)).toList();
  }

  Future<Contact?> getContactById(String id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Contact.fromMap(maps.first);
  }

  Future<List<Contact>> getFavoriteContacts() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'isFavorite = 1',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return maps.map((m) => Contact.fromMap(m)).toList();
  }

  Future<List<Contact>> searchContacts(String query) async {
    final db = await database;
    final q = '%${query.toLowerCase()}%';
    final maps = await db.query(
      _tableName,
      where: 'LOWER(name) LIKE ? OR phone LIKE ? OR LOWER(email) LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return maps.map((m) => Contact.fromMap(m)).toList();
  }

  Future<String> insertContact(Contact contact) async {
    final db = await database;
    await db.insert(
      _tableName,
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return contact.id;
  }

  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      _tableName,
      contact.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(String id) async {
    final db = await database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleFavorite(String id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      _tableName,
      {
        'isFavorite': isFavorite ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
