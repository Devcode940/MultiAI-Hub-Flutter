/// Prompt model for prompt library
class Prompt {
  final int? id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;

  const Prompt({
    this.id,
    required this.title,
    required this.content,
    this.category = 'General',
    required this.createdAt,
  });

  Prompt copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
  }) {
    return Prompt(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Prompt.fromMap(Map<String, dynamic> map) {
    return Prompt(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String? ?? 'General',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
