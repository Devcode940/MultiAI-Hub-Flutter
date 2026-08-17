import 'package:flutter/material.dart';
import 'package:multiai_hub/services/analytics/analytics_service.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:intl/intl.dart';

/// Analytics Dashboard screen - usage statistics and charts
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  final AnalyticsService _analytics = AnalyticsService.instance;
  List<UsageStat> _topProviders = [];
  Map<AiCategory, int> _categoryBreakdown = {};
  Map<String, int> _dailyUsage = {};
  int _totalUsage = 0;
  bool _isLoading = true;
  int _selectedDays = 30;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _analytics.ensureTable();
    _topProviders = await _analytics.getTopProviders(limit: 10, days: _selectedDays);
    _categoryBreakdown = await _analytics.getCategoryBreakdown(days: _selectedDays);
    _dailyUsage = await _analytics.getDailyUsage(days: 7);
    _totalUsage = await _analytics.getTotalUsage(days: _selectedDays);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Overview'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Categories'),
            Tab(icon: Icon(Icons.timeline), text: 'Trends'),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            onSelected: (days) {
              _selectedDays = days;
              _loadData();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 days')),
              const PopupMenuItem(value: 90, child: Text('Last 90 days')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('$_selectedDays days', style: theme.textTheme.bodySmall),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme, colorScheme),
                _buildCategoriesTab(theme, colorScheme),
                _buildTrendsTab(theme, colorScheme),
              ],
            ),
    );
  }

  /// Overview tab - top providers + summary stats
  Widget _buildOverviewTab(ThemeData theme, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary stat cards
          Row(
            children: [
              _buildStatCard(theme, colorScheme, 'Total Uses', '$_totalUsage', Icons.touch_app, colorScheme.primary),
              const SizedBox(width: 12),
              _buildStatCard(theme, colorScheme, 'Providers', '${_topProviders.length}', Icons.hub, colorScheme.tertiary),
              const SizedBox(width: 12),
              _buildStatCard(theme, colorScheme, 'Categories', '${_categoryBreakdown.length}', Icons.category, colorScheme.secondary),
            ],
          ),
          const SizedBox(height: 24),

          // Top providers
          Text('Most Used Providers', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (_topProviders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No usage data yet', style: theme.textTheme.bodyMedium),
              ),
            )
          else
            ..._topProviders.asMap().entries.map((entry) {
              final index = entry.key;
              final stat = entry.value;
              final maxCount = _topProviders.first.count;
              final percentage = (stat.count / maxCount).clamp(0.0, 1.0);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Rank
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: index < 3 ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: index < 3 ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Provider name + bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stat.providerName, style: theme.textTheme.titleSmall),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage,
                                minHeight: 6,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Count
                      Text(
                        '${stat.count}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  /// Categories tab - category breakdown
  Widget _buildCategoriesTab(ThemeData theme, ColorScheme colorScheme) {
    if (_categoryBreakdown.isEmpty) {
      return Center(child: Text('No data yet', style: theme.textTheme.bodyMedium));
    }

    final total = _categoryBreakdown.values.fold(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: _categoryBreakdown.entries.map((entry) {
        final percentage = (entry.value / total * 100).round();
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Text(entry.key.emoji, style: const TextStyle(fontSize: 28)),
            title: Text(entry.key.label),
            subtitle: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: entry.value / total,
                minHeight: 4,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            trailing: Text(
              '$percentage%',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Trends tab - daily usage chart
  Widget _buildTrendsTab(ThemeData theme, ColorScheme colorScheme) {
    if (_dailyUsage.isEmpty) {
      return Center(child: Text('No data yet', style: theme.textTheme.bodyMedium));
    }

    final maxVal = _dailyUsage.values.fold(0, (a, b) => a > b ? a : b).clamp(1, double.infinity).toInt();
    final entries = _dailyUsage.entries.toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Usage (Last 7 Days)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: entries.map((entry) {
                final height = (entry.value / maxVal).clamp(0.05, 1.0);
                final dayLabel = DateFormat.E().format(DateTime.parse(entry.date));
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${entry.value}', style: theme.textTheme.labelSmall),
                        const SizedBox(height: 4),
                        Container(
                          height: height * 200,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(dayLabel, style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Stat card widget
  Widget _buildStatCard(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
