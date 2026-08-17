import 'package:multiai_hub/data/database/app_database.dart';
import 'package:multiai_hub/data/models/models.dart';

/// Single data boundary - mirrors Kotlin AiRepository
class AiRepository {
  final AppDatabase _db = AppDatabase.instance;

  // ============ Providers ============

  Future<List<AiProvider>> getAllProviders() => _db.getAllProviders();

  Future<List<AiProvider>> getProvidersByCategory(AiCategory category) =>
      _db.getProvidersByCategory(category);

  Future<List<AiProvider>> searchProviders(String query) =>
      _db.searchProviders(query);

  Future<List<AiProvider>> getFavoriteProviders() => _db.getFavoriteProviders();

  Future<AiProvider> addCustomProvider(String name, String url, {String description = ''}) async {
    final validatedUrl = _validateAndNormalizeUrl(url);
    final provider = AiProvider(
      name: name.trim(),
      url: validatedUrl,
      category: AiCategory.custom,
      isCustom: true,
      description: description,
      addedAt: DateTime.now(),
    );
    return _db.insertProvider(provider);
  }

  Future<void> toggleFavorite(AiProvider provider) => _db.toggleFavorite(provider);

  Future<void> updateLastUsed(AiProvider provider) => _db.updateLastUsed(provider);

  Future<void> deleteProvider(int id) => _db.deleteProvider(id);

  /// HTTPS enforcement - mirrors Kotlin UrlValidator
  String _validateAndNormalizeUrl(String url) {
    var normalized = url.trim();
    if (normalized.isEmpty) {
      throw RepositoryException('URL cannot be empty');
    }
    if (normalized.length > 2048) {
      throw RepositoryException('URL exceeds maximum length of 2048 characters');
    }
    // Add https:// if no scheme
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    // Force HTTPS
    if (normalized.startsWith('http://')) {
      normalized = normalized.replaceFirst('http://', 'https://');
    }
    // Block dangerous schemes
    final dangerousSchemes = ['javascript:', 'file:', 'content:', 'data:', 'intent:'];
    for (final scheme in dangerousSchemes) {
      if (normalized.startsWith(scheme)) {
        throw RepositoryException('Dangerous URL scheme blocked: $scheme');
      }
    }
    return normalized;
  }

  // ============ Notes ============

  Future<List<Note>> getAllNotes() => _db.getAllNotes();

  Future<Note> addNote(String title, String content) {
    final now = DateTime.now();
    return _db.insertNote(Note(title: title, content: content, createdAt: now, updatedAt: now));
  }

  Future<void> updateNote(Note note) => _db.updateNote(note);

  Future<void> deleteNote(int id) => _db.deleteNote(id);

  // ============ Prompts ============

  Future<List<Prompt>> getAllPrompts() => _db.getAllPrompts();

  Future<Prompt> addPrompt(String title, String content, {String category = 'General'}) {
    return _db.insertPrompt(Prompt(
      title: title,
      content: content,
      category: category,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> deletePrompt(int id) => _db.deletePrompt(id);
}

/// Custom exception for repository operations - mirrors Kotlin RepositoryException
class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);
  @override
  String toString() => 'RepositoryException: $message';
}
