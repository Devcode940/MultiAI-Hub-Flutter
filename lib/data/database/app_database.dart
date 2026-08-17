import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/utils/default_ai_providers.dart';

/// Local database helper - mirrors the Kotlin Room database
class AppDatabase {
  static const _dbName = 'multiai_hub.db';
  static const _dbVersion = 2;
  static AppDatabase? _instance;
  static Database? _database;

  AppDatabase._();
  static AppDatabase get instance => _instance ??= AppDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // AI Providers table
    await db.execute('''
      CREATE TABLE ai_providers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        url TEXT NOT NULL UNIQUE,
        iconUrl TEXT NOT NULL DEFAULT '',
        category INTEGER NOT NULL DEFAULT 0,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        isCustom INTEGER NOT NULL DEFAULT 0,
        description TEXT NOT NULL DEFAULT '',
        addedAt INTEGER NOT NULL,
        lastUsedAt INTEGER
      )
    ''');

    // Notes table
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Prompts table
    await db.execute('''
      CREATE TABLE prompts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'General',
        createdAt INTEGER NOT NULL
      )
    ''');

    // Seed default providers
    await _seedDefaultProviders(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration 1→2: Add prompts table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS prompts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          category TEXT NOT NULL DEFAULT 'General',
          createdAt INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<void> _seedDefaultProviders(Database db) async {
    final providers = DefaultAiProviders.all;
    for (final provider in providers) {
      await db.insert('ai_providers', provider.toMap());
    }
  }

  // ============ AI Provider CRUD ============

  Future<List<AiProvider>> getAllProviders() async {
    final db = await database;
    final maps = await db.query(
      'ai_providers',
      orderBy: 'isFavorite DESC, name ASC',
    );
    return maps.map((m) => AiProvider.fromMap(m)).toList();
  }

  Future<List<AiProvider>> getProvidersByCategory(AiCategory category) async {
    final db = await database;
    final maps = await db.query(
      'ai_providers',
      where: 'category = ?',
      whereArgs: [category.index],
      orderBy: 'name ASC',
    );
    return maps.map((m) => AiProvider.fromMap(m)).toList();
  }

  Future<List<AiProvider>> searchProviders(String query) async {
    final db = await database;
    final maps = await db.query(
      'ai_providers',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((m) => AiProvider.fromMap(m)).toList();
  }

  Future<List<AiProvider>> getFavoriteProviders() async {
    final db = await database;
    final maps = await db.query(
      'ai_providers',
      where: 'isFavorite = 1',
      orderBy: 'name ASC',
    );
    return maps.map((m) => AiProvider.fromMap(m)).toList();
  }

  Future<AiProvider> insertProvider(AiProvider provider) async {
    final db = await database;
    final id = await db.insert('ai_providers', provider.toMap());
    return provider.copyWith(id: id);
  }

  Future<void> updateProvider(AiProvider provider) async {
    final db = await database;
    await db.update(
      'ai_providers',
      provider.toMap(),
      where: 'id = ?',
      whereArgs: [provider.id],
    );
  }

  Future<void> deleteProvider(int id) async {
    final db = await database;
    await db.delete('ai_providers', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavorite(AiProvider provider) async {
    await updateProvider(provider.copyWith(isFavorite: !provider.isFavorite));
  }

  Future<void> updateLastUsed(AiProvider provider) async {
    await updateProvider(provider.copyWith(lastUsedAt: DateTime.now()));
  }

  // ============ Notes CRUD ============

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'updatedAt DESC');
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<Note> insertNote(Note note) async {
    final db = await database;
    final id = await db.insert('notes', note.toMap());
    return note.copyWith(id: id);
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // ============ Prompts CRUD ============

  Future<List<Prompt>> getAllPrompts() async {
    final db = await database;
    final maps = await db.query('prompts', orderBy: 'createdAt DESC');
    return maps.map((m) => Prompt.fromMap(m)).toList();
  }

  Future<Prompt> insertPrompt(Prompt prompt) async {
    final db = await database;
    final id = await db.insert('prompts', prompt.toMap());
    return prompt.copyWith(id: id);
  }

  Future<void> deletePrompt(int id) async {
    final db = await database;
    await db.delete('prompts', where: 'id = ?', whereArgs: [id]);
  }
}
