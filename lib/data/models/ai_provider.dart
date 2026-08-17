/// AI Provider category enumeration
enum AiCategory {
  chat('Chat', '💬'),
  coding('Coding', '💻'),
  writing('Writing', '✍️'),
  image('Image', '🎨'),
  search('Search', '🔍'),
  free('Free', '🆓'),
  custom('Custom', '⚙️'),
  favorite('Favorite', '⭐');

  const AiCategory(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// AI Provider model - mirrors the Kotlin Room entity
class AiProvider {
  final int? id;
  final String name;
  final String url;
  final String iconUrl;
  final AiCategory category;
  final bool isFavorite;
  final bool isCustom;
  final String description;
  final DateTime addedAt;
  final DateTime? lastUsedAt;

  const AiProvider({
    this.id,
    required this.name,
    required this.url,
    this.iconUrl = '',
    this.category = AiCategory.chat,
    this.isFavorite = false,
    this.isCustom = false,
    this.description = '',
    required this.addedAt,
    this.lastUsedAt,
  });

  AiProvider copyWith({
    int? id,
    String? name,
    String? url,
    String? iconUrl,
    AiCategory? category,
    bool? isFavorite,
    bool? isCustom,
    String? description,
    DateTime? addedAt,
    DateTime? lastUsedAt,
  }) {
    return AiProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      iconUrl: iconUrl ?? this.iconUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isCustom: isCustom ?? this.isCustom,
      description: description ?? this.description,
      addedAt: addedAt ?? this.addedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  /// Convert to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'iconUrl': iconUrl,
      'category': category.index,
      'isFavorite': isFavorite ? 1 : 0,
      'isCustom': isCustom ? 1 : 0,
      'description': description,
      'addedAt': addedAt.millisecondsSinceEpoch,
      'lastUsedAt': lastUsedAt?.millisecondsSinceEpoch,
    };
  }

  /// Create from database Map
  factory AiProvider.fromMap(Map<String, dynamic> map) {
    return AiProvider(
      id: map['id'] as int?,
      name: map['name'] as String,
      url: map['url'] as String,
      iconUrl: map['iconUrl'] as String? ?? '',
      category: AiCategory.values[map['category'] as int? ?? 0],
      isFavorite: (map['isFavorite'] as int?) == 1,
      isCustom: (map['isCustom'] as int?) == 1,
      description: map['description'] as String? ?? '',
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] as int),
      lastUsedAt: map['lastUsedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUsedAt'] as int)
          : null,
    );
  }

  @override
  String toString() => 'AiProvider(id: $id, name: $name, category: ${category.label})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiProvider && id == other.id && url == other.url;

  @override
  int get hashCode => id.hashCode ^ url.hashCode;
}
