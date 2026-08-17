import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported languages for the app
class AppLocale {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const AppLocale({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  static const locales = [
    AppLocale(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    AppLocale(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
    AppLocale(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
    AppLocale(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
    AppLocale(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    AppLocale(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    AppLocale(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    AppLocale(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇧🇷'),
    AppLocale(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    AppLocale(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
  ];
}

/// i18n service - manages app language and provides translations
class I18nService {
  static final I18nService _instance = I18nService._();
  static I18nService get instance => _instance;
  I18nService._();

  String _currentLocale = 'en';
  String get currentLocale => _currentLocale;

  /// Load saved locale preference
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocale = prefs.getString('app_locale') ?? 'en';
  }

  /// Set the app locale
  Future<void> setLocale(String code) async {
    _currentLocale = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', code);
  }

  /// Get a translated string by key
  String t(String key, {Map<String, String>? params}) {
    var text = _translations[_currentLocale]?[key] ?? _translations['en']?[key] ?? key;

    // Replace parameters
    if (params != null) {
      for (final entry in params.entries) {
        text = text.replaceAll('{${entry.key}}', entry.value);
      }
    }

    return text;
  }
}

/// Translation map - all UI strings in all supported languages
const _translations = <String, Map<String, String>>{
  'en': {
    'app_title': 'MultiAI Hub',
    'home': 'Home',
    'tabs': 'Tabs',
    'ask_all': 'Ask All',
    'analytics': 'Analytics',
    'notes': 'Notes',
    'compare': 'Compare',
    'settings': 'Settings',
    'search': 'Search',
    'add_custom': 'Add Custom AI',
    'no_providers': 'No AI providers found',
    'no_providers_hint': 'Try a different search or category',
    'loading': 'Loading...',
    'retry': 'Retry',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'create': 'Create',
    'close': 'Close',
    'send': 'Send',
    'send_to_all': 'Send to All',
    'selected': '{count} selected',
    'offline_banner': 'You\'re offline. Some features may use cached data.',
    'new_tab': 'New Tab',
    'close_all': 'Close All',
    'provider_open': 'Open in Browser',
    'provider_share': 'Share URL',
    'toggle_favorite': 'Toggle Favorite',
    'desktop_mode': 'Desktop Mode',
    'mobile_mode': 'Mobile Mode',
    'dark_mode': 'Dark Mode',
    'enable_js': 'Enable JavaScript',
    'block_popups': 'Block Popups',
    'clear_data': 'Clear All Data',
    'clear_data_confirm': 'This will permanently delete all your custom providers, notes, and prompts.',
    'version': 'Version',
    'built_with': 'Built with',
    'notes_empty': 'No notes yet',
    'notes_hint': 'Tap + to create your first note',
    'onboarding_welcome': 'Welcome to MultiAI Hub',
    'onboarding_desc': 'Access 30+ AI platforms from a single app.',
    'pipeline': 'Pipelines',
    'pipeline_run': 'Run',
    'pipeline_running': 'Running...',
    'theme': 'Theme',
    'language': 'Language',
    'voice_listening': 'Listening...',
    'ask_prompt': 'Enter a prompt to send to all selected AIs...',
  },
  'zh': {
    'app_title': '多AI中心',
    'home': '首页',
    'tabs': '标签页',
    'ask_all': '全员提问',
    'analytics': '分析',
    'notes': '笔记',
    'compare': '对比',
    'settings': '设置',
    'search': '搜索',
    'add_custom': '添加自定义AI',
    'no_providers': '未找到AI提供商',
    'no_providers_hint': '尝试不同的搜索或分类',
    'loading': '加载中...',
    'retry': '重试',
    'cancel': '取消',
    'save': '保存',
    'delete': '删除',
    'edit': '编辑',
    'create': '创建',
    'close': '关闭',
    'send': '发送',
    'send_to_all': '发送给全部',
    'selected': '已选择 {count} 个',
    'offline_banner': '您已离线。部分功能可能使用缓存数据。',
    'new_tab': '新标签',
    'close_all': '关闭全部',
    'desktop_mode': '桌面模式',
    'mobile_mode': '移动模式',
    'dark_mode': '深色模式',
    'version': '版本',
    'notes_empty': '暂无笔记',
    'notes_hint': '点击 + 创建第一条笔记',
    'onboarding_welcome': '欢迎使用多AI中心',
    'pipeline': '流水线',
    'pipeline_run': '运行',
    'theme': '主题',
    'language': '语言',
    'voice_listening': '正在聆听...',
    'ask_prompt': '输入要发送给所有选中AI的提示...',
  },
  'ja': {
    'app_title': 'マルチAIハブ',
    'home': 'ホーム',
    'tabs': 'タブ',
    'ask_all': '全員に質問',
    'analytics': '分析',
    'notes': 'メモ',
    'compare': '比較',
    'settings': '設定',
    'search': '検索',
    'add_custom': 'カスタムAIを追加',
    'no_providers': 'AIプロバイダーが見つかりません',
    'loading': '読み込み中...',
    'retry': '再試行',
    'cancel': 'キャンセル',
    'save': '保存',
    'delete': '削除',
    'send_to_all': '全員に送信',
    'offline_banner': 'オフラインです。キャッシュデータを使用する場合があります。',
    'dark_mode': 'ダークモード',
    'theme': 'テーマ',
    'language': '言語',
    'voice_listening': '聞いています...',
  },
  'es': {
    'app_title': 'MultiAI Hub',
    'home': 'Inicio',
    'tabs': 'Pestañas',
    'ask_all': 'Preguntar a Todos',
    'analytics': 'Análisis',
    'notes': 'Notas',
    'compare': 'Comparar',
    'settings': 'Configuración',
    'search': 'Buscar',
    'add_custom': 'Agregar IA Personalizada',
    'no_providers': 'No se encontraron proveedores de IA',
    'loading': 'Cargando...',
    'cancel': 'Cancelar',
    'save': 'Guardar',
    'delete': 'Eliminar',
    'send_to_all': 'Enviar a Todos',
    'dark_mode': 'Modo Oscuro',
    'theme': 'Tema',
    'language': 'Idioma',
  },
  'fr': {
    'app_title': 'MultiAI Hub',
    'home': 'Accueil',
    'tabs': 'Onglets',
    'ask_all': 'Demander à Tous',
    'analytics': 'Analyse',
    'notes': 'Notes',
    'compare': 'Comparer',
    'settings': 'Paramètres',
    'search': 'Rechercher',
    'add_custom': 'Ajouter une IA personnalisée',
    'no_providers': 'Aucun fournisseur IA trouvé',
    'loading': 'Chargement...',
    'cancel': 'Annuler',
    'save': 'Enregistrer',
    'delete': 'Supprimer',
    'dark_mode': 'Mode sombre',
    'theme': 'Thème',
    'language': 'Langue',
  },
  'de': {
    'app_title': 'MultiAI Hub',
    'home': 'Startseite',
    'tabs': 'Tabs',
    'ask_all': 'Alle fragen',
    'analytics': 'Analyse',
    'notes': 'Notizen',
    'compare': 'Vergleichen',
    'settings': 'Einstellungen',
    'search': 'Suchen',
    'add_custom': 'Benutzerdefinierte AI hinzufügen',
    'no_providers': 'Keine AI-Anbieter gefunden',
    'loading': 'Laden...',
    'cancel': 'Abbrechen',
    'save': 'Speichern',
    'delete': 'Löschen',
    'dark_mode': 'Dunkelmodus',
    'theme': 'Thema',
    'language': 'Sprache',
  },
};

/// Language selection screen
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18nService.instance;

    return Scaffold(
      appBar: AppBar(title: Text(i18n.t('language'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppLocale.locales.length,
        itemBuilder: (context, index) {
          final locale = AppLocale.locales[index];
          final isSelected = i18n.currentLocale == locale.code;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Text(locale.flag, style: const TextStyle(fontSize: 28)),
              title: Text(locale.nativeName, style: theme.textTheme.titleSmall),
              subtitle: Text(locale.name, style: theme.textTheme.bodySmall),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              selected: isSelected,
              onTap: () async {
                await i18n.setLocale(locale.code);
                // In production: would trigger app-level locale change
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Language changed to ${locale.nativeName}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
