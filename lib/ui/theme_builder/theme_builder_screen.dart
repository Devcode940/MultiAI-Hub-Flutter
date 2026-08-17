import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pre-built theme presets
class ThemePreset {
  final String name;
  final Color seedColor;
  final String emoji;
  final String description;

  const ThemePreset({
    required this.name,
    required this.seedColor,
    required this.emoji,
    required this.description,
  });

  static const presets = [
    ThemePreset(name: 'Purple', seedColor: Color(0xFF6750A4), emoji: '💜', description: 'Default Material 3'),
    ThemePreset(name: 'Ocean', seedColor: Color(0xFF0061A4), emoji: '🌊', description: 'Cool blue tones'),
    ThemePreset(name: 'Forest', seedColor: Color(0xFF006E1C), emoji: '🌲', description: 'Natural greens'),
    ThemePreset(name: 'Sunset', seedColor: Color(0xFF9C4232), emoji: '🌅', description: 'Warm oranges'),
    ThemePreset(name: 'Rose', seedColor: Color(0xFF9C4354), emoji: '🌹', description: 'Elegant pinks'),
    ThemePreset(name: 'Gold', seedColor: Color(0xFF7D5700), emoji: '✨', description: 'Rich golds'),
    ThemePreset(name: 'Midnight', seedColor: Color(0xFF1B1B3A), emoji: '🌙', description: 'Dark & moody'),
    ThemePreset(name: 'Arctic', seedColor: Color(0xFF00677F), emoji: '❄️', description: 'Icy blues'),
  ];
}

/// Custom theming service - manages user's theme preferences
class ThemeService {
  static final ThemeService _instance = ThemeService._();
  static ThemeService get instance => _instance;
  ThemeService._();

  Color _seedColor = const Color(0xFF6750A4);
  bool _useDarkMode = true;
  double _cornerRadius = 16;
  double _spacingDensity = 1.0; // 0.5=compact, 1.0=normal, 1.5=spacious
  String _fontFamily = 'System';

  Color get seedColor => _seedColor;
  bool get useDarkMode => _useDarkMode;
  double get cornerRadius => _cornerRadius;
  double get spacingDensity => _spacingDensity;
  String get fontFamily => _fontFamily;

  /// Load saved theme preferences
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final seedValue = prefs.getInt('theme_seed_color');
    if (seedValue != null) _seedColor = Color(seedValue);
    _useDarkMode = prefs.getBool('theme_dark_mode') ?? true;
    _cornerRadius = prefs.getDouble('theme_corner_radius') ?? 16;
    _spacingDensity = prefs.getDouble('theme_spacing') ?? 1.0;
    _fontFamily = prefs.getString('theme_font') ?? 'System';
  }

  /// Save seed color
  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_seed_color', color.value);
  }

  /// Apply a preset theme
  Future<void> applyPreset(ThemePreset preset) async {
    await setSeedColor(preset.seedColor);
  }

  /// Toggle dark mode
  Future<void> setDarkMode(bool value) async {
    _useDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_dark_mode', value);
  }

  /// Set corner radius
  Future<void> setCornerRadius(double value) async {
    _cornerRadius = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('theme_corner_radius', value);
  }

  /// Set spacing density
  Future<void> setSpacingDensity(double value) async {
    _spacingDensity = value.clamp(0.5, 1.5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('theme_spacing', _spacingDensity);
  }

  /// Build the light theme
  ThemeData buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light);
    return _buildTheme(colorScheme);
  }

  /// Build the dark theme
  ThemeData buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark);
    return _buildTheme(colorScheme);
  }

  ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cornerRadius)),
        clipBehavior: Clip.antiAlias,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cornerRadius)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(_cornerRadius * 0.75)),
      ),
    );
  }
}

/// Theme builder screen - visual theme customization
class ThemeBuilderScreen extends StatefulWidget {
  const ThemeBuilderScreen({super.key});

  @override
  State<ThemeBuilderScreen> createState() => _ThemeBuilderScreenState();
}

class _ThemeBuilderScreenState extends State<ThemeBuilderScreen> {
  final ThemeService _themeService = ThemeService.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Preset themes
          Text('Preset Themes', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: ThemePreset.presets.length,
            itemBuilder: (context, index) {
              final preset = ThemePreset.presets[index];
              final isSelected = _themeService.seedColor.value == preset.seedColor.value;
              return GestureDetector(
                onTap: () {
                  _themeService.applyPreset(preset);
                  setState(() {});
                },
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: preset.seedColor,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: colorScheme.onSurface, width: 3) : null,
                      ),
                      child: Center(child: Text(preset.emoji, style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(height: 4),
                    Text(preset.name, style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Custom color picker
          Text('Custom Color', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
              Colors.indigo, Colors.blue, Colors.cyan, Colors.teal,
              Colors.green, Colors.lightGreen, Colors.lime, Colors.yellow,
              Colors.amber, Colors.orange, Colors.deepOrange, Colors.brown,
            ].map((color) {
              final isSelected = _themeService.seedColor.value == color.value;
              return GestureDetector(
                onTap: () {
                  _themeService.setSeedColor(color);
                  setState(() {});
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Corner radius slider
          Text('Corner Radius', style: theme.textTheme.titleMedium),
          Slider(
            value: _themeService.cornerRadius,
            min: 0,
            max: 28,
            divisions: 7,
            label: '${_themeService.cornerRadius.round()}px',
            onChanged: (v) {
              _themeService.setCornerRadius(v);
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Spacing density
          Text('Spacing Density', style: theme.textTheme.titleMedium),
          Row(
            children: [
              const Text('Compact'),
              Expanded(
                child: Slider(
                  value: _themeService.spacingDensity,
                  min: 0.5,
                  max: 1.5,
                  divisions: 4,
                  onChanged: (v) {
                    _themeService.setSpacingDensity(v);
                    setState(() {});
                  },
                ),
              ),
              const Text('Spacious'),
            ],
          ),
          const SizedBox(height: 24),

          // Dark mode toggle
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              value: _themeService.useDarkMode,
              onChanged: (v) {
                _themeService.setDarkMode(v);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
