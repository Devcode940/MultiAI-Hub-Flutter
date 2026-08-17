import 'package:flutter/material.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/data/database/app_database.dart';
import 'package:intl/intl.dart';

/// Analytics service - tracks usage patterns
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;
  AnalyticsService._();

  /// Record a provider usage event
  Future<void> recordUsage(AiProvider provider) async {
    final db = await AppDatabase.instance.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Check if entry exists for today
    final existing = await db.query(
      'analytics',
      where: 'providerId = ? AND date = ?',
      whereArgs: [provider.id, today],
    );

    if (existing.isNotEmpty) {
      // Increment count
      await db.update(
        'analytics',
        {'count': (existing.first['count'] as int) + 1},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // Create new entry
      await db.insert('analytics', {
        'providerId': provider.id!,
        'providerName': provider.name,
        'category': provider.category.index,
        'date': today,
        'count': 1,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  /// Get usage stats for the last N days
  Future<List<UsageStat>> getStats({int days = 30}) async {
    final db = await AppDatabase.instance.database;
    final since = DateTime.now().subtract(Duration(days: days));
    final sinceStr = DateFormat('yyyy-MM-dd').format(since);

    final maps = await db.query(
      'analytics',
      where: 'date >= ?',
      whereArgs: [sinceStr],
      orderBy: 'count DESC',
    );

    return maps.map((m) => UsageStat.fromMap(m)).toList();
  }

  /// Get total usage count
  Future<int> getTotalUsage({int days = 30}) async {
    final stats = await getStats(days: days);
    return stats.fold(0, (sum, s) => sum + s.count);
  }

  /// Get most used providers
  Future<List<UsageStat>> getTopProviders({int limit = 5, int days = 30}) async {
    final stats = await getStats(days: days);
    // Aggregate by provider
    final byProvider = <int, UsageStat>{};
    for (final stat in stats) {
      final existing = byProvider[stat.providerId];
      if (existing != null) {
        byProvider[stat.providerId] = UsageStat(
          providerId: stat.providerId,
          providerName: stat.providerName,
          category: stat.category,
          date: 'aggregate',
          count: existing.count + stat.count,
          timestamp: stat.timestamp,
        );
      } else {
        byProvider[stat.providerId] = stat;
      }
    }
    final sorted = byProvider.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return sorted.take(limit).toList();
  }

  /// Get category breakdown
  Future<Map<AiCategory, int>> getCategoryBreakdown({int days = 30}) async {
    final stats = await getStats(days: days);
    final breakdown = <AiCategory, int>{};
    for (final stat in stats) {
      final cat = AiCategory.values[stat.category];
      breakdown[cat] = (breakdown[cat] ?? 0) + stat.count;
    }
    return breakdown;
  }

  /// Get daily usage for chart
  Future<Map<String, int>> getDailyUsage({int days = 7}) async {
    final db = await AppDatabase.instance.database;
    final result = <String, int>{};

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final maps = await db.query(
        'analytics',
        where: 'date = ?',
        whereArgs: [dateStr],
      );

      final total = maps.fold(0, (sum, m) => sum + (m['count'] as int));
      result[dateStr] = total;
    }

    return result;
  }

  /// Ensure analytics table exists
  Future<void> ensureTable() async {
    final db = await AppDatabase.instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS analytics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        providerId INTEGER NOT NULL,
        providerName TEXT NOT NULL,
        category INTEGER NOT NULL,
        date TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 1,
        timestamp INTEGER NOT NULL
      )
    ''');
  }
}

/// Usage statistic model
class UsageStat {
  final int providerId;
  final String providerName;
  final int category;
  final String date;
  final int count;
  final DateTime timestamp;

  const UsageStat({
    required this.providerId,
    required this.providerName,
    required this.category,
    required this.date,
    required this.count,
    required this.timestamp,
  });

  factory UsageStat.fromMap(Map<String, dynamic> map) {
    return UsageStat(
      providerId: map['providerId'] as int,
      providerName: map['providerName'] as String,
      category: map['category'] as int,
      date: map['date'] as String,
      count: map['count'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
