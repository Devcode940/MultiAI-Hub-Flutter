import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multiai_hub/viewmodel/settings_viewmodel.dart';
import 'package:multiai_hub/ui/theme_builder/theme_builder_screen.dart';
import 'package:multiai_hub/services/i18n/i18n_service.dart';

/// Settings screen - now with Theme and Language links
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final vm = context.watch<SettingsViewModel>();
    final i18n = I18nService.instance;

    return Scaffold(
      appBar: AppBar(title: Text(i18n.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ──
          Text('Appearance', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                // Theme builder
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: Text(i18n.t('theme')),
                  subtitle: const Text('Colors, presets, spacing'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ThemeBuilderScreen()),
                  ),
                ),
                // Language
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(i18n.t('language')),
                  subtitle: Text(_getCurrentLanguageName()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LanguageScreen()),
                  ),
                ),
                // Dark mode
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: Text(i18n.t('dark_mode')),
                  value: vm.useDarkMode,
                  onChanged: vm.setDarkMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── WebView ──
          Text('WebView', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.monitor),
                  title: Text(i18n.t('desktop_mode')),
                  subtitle: const Text('Load desktop versions of websites'),
                  value: vm.useDesktopMode,
                  onChanged: vm.setDesktopMode,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.javascript),
                  title: Text(i18n.t('enable_js')),
                  subtitle: const Text('Required for most AI platforms'),
                  value: vm.enableJavaScript,
                  onChanged: vm.setEnableJavaScript,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.block),
                  title: Text(i18n.t('block_popups')),
                  subtitle: const Text('Prevent websites from opening new windows'),
                  value: vm.blockPopups,
                  onChanged: vm.setBlockPopups,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Security ──
          Text('Security', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.https),
                  title: const Text('HTTPS Only'),
                  subtitle: const Text('Block all HTTP connections'),
                  value: true,
                  onChanged: null, // Always enforced
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.lock),
                  title: const Text('Encrypt Custom URLs'),
                  subtitle: const Text('Store URLs encrypted at rest'),
                  value: true,
                  onChanged: null,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.security),
                  title: const Text('Content Security Policy'),
                  subtitle: const Text('Inject CSP headers in WebView'),
                  value: true,
                  onChanged: null,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.cookie),
                  title: const Text('Persist Cookies'),
                  subtitle: const Text('Save login sessions between visits'),
                  value: true,
                  onChanged: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── About ──
          Text('About', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(i18n.t('version')),
                  trailing: Text('2.0.0', style: theme.textTheme.bodyMedium),
                ),
                ListTile(
                  title: Text(i18n.t('built_with')),
                  trailing: Text('Flutter', style: theme.textTheme.bodyMedium),
                ),
                const ListTile(
                  title: Text('License'),
                  trailing: Text('MIT'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Danger Zone ──
          Text('Danger Zone', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.error)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Clear All Data', style: TextStyle(color: colorScheme.error)),
                  subtitle: const Text('Delete all providers, notes, and prompts'),
                  leading: Icon(Icons.delete_forever, color: colorScheme.error),
                  onTap: () => _showClearDataDialog(context),
                ),
                ListTile(
                  title: Text('Clear Cache', style: TextStyle(color: colorScheme.error)),
                  subtitle: const Text('Delete all cached pages and cookies'),
                  leading: Icon(Icons.cleaning_services, color: colorScheme.error),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentLanguageName() {
    final code = I18nService.instance.currentLocale;
    final locale = AppLocale.locales.where((l) => l.code == code);
    return locale.isNotEmpty ? '${locale.first.flag} ${locale.first.nativeName}' : '🇺🇸 English';
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will permanently delete all your custom providers, notes, prompts, and cached data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
