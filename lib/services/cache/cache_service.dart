import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Cache service - stores WebView page data for offline access
class CacheService {
  static final CacheService _instance = CacheService._();
  static CacheService get instance => _instance;
  CacheService._();

  Database? _db;
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  /// Initialize cache database
  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'multiai_cache.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE page_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT NOT NULL UNIQUE,
            title TEXT NOT NULL DEFAULT '',
            content TEXT NOT NULL,
            headers TEXT NOT NULL DEFAULT '{}',
            cachedAt INTEGER NOT NULL,
            expiresAt INTEGER NOT NULL,
            sizeBytes INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('CREATE INDEX idx_cache_url ON page_cache(url)');
        await db.execute('CREATE INDEX idx_cache_expires ON page_cache(expiresAt)');
        
        // Offline queue table for deferred requests
        await db.execute('''
          CREATE TABLE IF NOT EXISTS offline_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT NOT NULL,
            method TEXT NOT NULL,
            body TEXT NOT NULL DEFAULT '{}',
            queuedAt INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_offline_queued ON offline_queue(queuedAt)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS offline_queue (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              url TEXT NOT NULL,
              method TEXT NOT NULL,
              body TEXT NOT NULL DEFAULT '{}',
              queuedAt INTEGER NOT NULL
            )
          ''');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_offline_queued ON offline_queue(queuedAt)');
        }
      },
    );

    // Monitor connectivity
    Connectivity().onConnectivityChanged.listen((results) {
      _isOffline = results.every((r) => r == ConnectivityResult.none);
    });
  }

  /// Cache a page's content
  Future<void> cachePage({
    required String url,
    required String content,
    String title = '',
    Map<String, String>? headers,
    Duration ttl = const Duration(hours: 24),
  }) async {
    if (_db == null) return;
    final now = DateTime.now();
    final expiresAt = now.add(ttl);

    await _db!.insert(
      'page_cache',
      {
        'url': url,
        'title': title,
        'content': content,
        'headers': jsonEncode(headers ?? {}),
        'cachedAt': now.millisecondsSinceEpoch,
        'expiresAt': expiresAt.millisecondsSinceEpoch,
        'sizeBytes': content.length,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get cached page content
  Future<CachedPage?> getCachedPage(String url) async {
    if (_db == null) return null;
    final now = DateTime.now().millisecondsSinceEpoch;

    final maps = await _db!.query(
      'page_cache',
      where: 'url = ? AND expiresAt > ?',
      whereArgs: [url, now],
    );

    if (maps.isEmpty) return null;
    return CachedPage.fromMap(maps.first);
  }

  /// Check if a URL is cached
  Future<bool> isCached(String url) async {
    final cached = await getCachedPage(url);
    return cached != null;
  }

  /// Get all cached pages
  Future<List<CachedPage>> getAllCachedPages() async {
    if (_db == null) return [];
    final now = DateTime.now().millisecondsSinceEpoch;
    final maps = await _db!.query(
      'page_cache',
      where: 'expiresAt > ?',
      whereArgs: [now],
      orderBy: 'cachedAt DESC',
    );
    return maps.map((m) => CachedPage.fromMap(m)).toList();
  }

  /// Get total cache size
  Future<int> getCacheSize() async {
    if (_db == null) return 0;
    final result = await _db!.rawQuery('SELECT SUM(sizeBytes) as total FROM page_cache');
    return (result.first['total'] as int?) ?? 0;
  }

  /// Clear expired entries
  Future<void> clearExpired() async {
    if (_db == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db!.delete('page_cache', where: 'expiresAt <= ?', whereArgs: [now]);
  }

  /// Clear all cache
  Future<void> clearAll() async {
    if (_db == null) return;
    await _db!.delete('page_cache');
  }

  /// Queue a request for when connectivity returns (offline queue)
  Future<void> queueOfflineRequest({
    required String url,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    if (_db == null) return;
    await _db!.insert('offline_queue', {
      'url': url,
      'method': method,
      'body': jsonEncode(body ?? {}),
      'queuedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Process offline queue when connectivity returns
  Future<void> processOfflineQueue() async {
    if (_db == null || _isOffline) return;
    // Process queued requests
    final maps = await _db!.query('offline_queue', orderBy: 'queuedAt ASC');
    for (final map in maps) {
      // Process each request - in production, this would replay HTTP requests
      debugPrint('Processing offline request: ${map['method']} ${map['url']}');
    }
    await _db!.delete('offline_queue');
  }
}

/// Cached page model
class CachedPage {
  final int? id;
  final String url;
  final String title;
  final String content;
  final Map<String, String> headers;
  final DateTime cachedAt;
  final DateTime expiresAt;
  final int sizeBytes;

  const CachedPage({
    this.id,
    required this.url,
    required this.title,
    required this.content,
    this.headers = const {},
    required this.cachedAt,
    required this.expiresAt,
    this.sizeBytes = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  String get sizeFormatted => _formatBytes(sizeBytes);

  factory CachedPage.fromMap(Map<String, dynamic> map) {
    return CachedPage(
      id: map['id'] as int?,
      url: map['url'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      headers: Map<String, String>.from(jsonDecode(map['headers'] as String)),
      cachedAt: DateTime.fromMillisecondsSinceEpoch(map['cachedAt'] as int),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] as int),
      sizeBytes: map['sizeBytes'] as int,
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}
