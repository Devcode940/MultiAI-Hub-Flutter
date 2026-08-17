import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:webview_flutter/webview_flutter.dart';

/// Cookie persistence service - saves/restores WebView cookies per provider
class CookieManagerService {
  static final CookieManagerService _instance = CookieManagerService._();
  static CookieManagerService get instance => _instance;
  CookieManagerService._();

  Database? _db;

  /// Initialize cookie storage database
  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'cookies.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cookies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            domain TEXT NOT NULL,
            name TEXT NOT NULL,
            value TEXT NOT NULL,
            path TEXT NOT NULL DEFAULT '/',
            isSecure INTEGER NOT NULL DEFAULT 1,
            isHttpOnly INTEGER NOT NULL DEFAULT 1,
            expiresAt INTEGER,
            createdAt INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE UNIQUE INDEX idx_cookie_unique ON cookies(domain, name, path)');
      },
    );
  }

  /// Save cookies for a domain
  Future<void> saveCookies(String url) async {
    if (_db == null) return;
    try {
      final cookieManager = WebCookieManager();
      final uri = Uri.parse(url);
      final cookies = await cookieManager.getCookies(uri.toString());

      for (final cookie in cookies) {
        await _db!.insert(
          'cookies',
          {
            'domain': uri.host,
            'name': cookie.name,
            'value': cookie.value,
            'path': cookie.path ?? '/',
            'isSecure': cookie.secure ? 1 : 0,
            'isHttpOnly': cookie.httpOnly ? 1 : 0,
            'expiresAt': cookie.expires?.millisecondsSinceEpoch,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('CookieManager: Error saving cookies: $e');
    }
  }

  /// Restore cookies for a domain
  Future<void> restoreCookies(String url) async {
    if (_db == null) return;
    try {
      final uri = Uri.parse(url);
      final maps = await _db!.query(
        'cookies',
        where: 'domain = ?',
        whereArgs: [uri.host],
      );

      final cookieManager = WebCookieManager();
      for (final map in maps) {
        await cookieManager.setCookie(
          url,
          '${map['name']}=${map['value']}; path=${map['path']}; '
          '${(map['isSecure'] as int) == 1 ? 'secure; ' : ''}'
          '${(map['isHttpOnly'] as int) == 1 ? 'httponly; ' : ''}',
        );
      }
    } catch (e) {
      debugPrint('CookieManager: Error restoring cookies: $e');
    }
  }

  /// Clear cookies for a specific domain
  Future<void> clearCookies(String url) async {
    if (_db == null) return;
    final uri = Uri.parse(url);
    await _db!.delete('cookies', where: 'domain = ?', whereArgs: [uri.host]);
  }

  /// Clear all cookies
  Future<void> clearAll() async {
    if (_db == null) return;
    await _db!.delete('cookies');
  }
}

/// WebCookieManager wrapper for platform-specific cookie access
class WebCookieManager {
  Future<List<Cookie>> getCookies(String url) async {
    // In production, use WebViewCookieManagerPlatform
    // final manager = WebViewCookieManagerPlatform();
    // return await manager.getCookies(url);
    return [];
  }

  Future<void> setCookie(String url, String cookie) async {
    // In production, use platform-specific cookie setting
    debugPrint('Setting cookie for $url: $cookie');
  }
}

/// Simple cookie model
class Cookie {
  final String name;
  final String value;
  final String? path;
  final bool secure;
  final bool httpOnly;
  final DateTime? expires;

  const Cookie({
    required this.name,
    required this.value,
    this.path,
    this.secure = true,
    this.httpOnly = true,
    this.expires,
  });
}
