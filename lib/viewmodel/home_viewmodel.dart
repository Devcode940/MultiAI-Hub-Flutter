import 'package:flutter/foundation.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/data/repository/ai_repository.dart';

/// Home screen ViewModel - manages AI providers list, categories, and search
class HomeViewModel extends ChangeNotifier {
  final AiRepository _repository = AiRepository();

  List<AiProvider> _allProviders = [];
  List<AiProvider> _filteredProviders = [];
  AiCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  // Getters
  List<AiProvider> get providers => _filteredProviders;
  AiCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AiCategory> get categories => AiCategory.values;

  /// Load all providers from database
  Future<void> loadProviders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allProviders = await _repository.getAllProviders();
      _applyFilter();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a category filter
  void selectCategory(AiCategory? category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    _applyFilter();
    notifyListeners();
  }

  /// Apply category and search filters
  void _applyFilter() {
    var result = _allProviders;

    // Category filter
    if (_selectedCategory == AiCategory.favorite) {
      result = result.where((p) => p.isFavorite).toList();
    } else if (_selectedCategory != null) {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();
    }

    _filteredProviders = result;
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(AiProvider provider) async {
    try {
      await _repository.toggleFavorite(provider);
      await loadProviders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Add a custom AI provider
  Future<void> addCustomProvider(String name, String url, {String description = ''}) async {
    try {
      await _repository.addCustomProvider(name, url, description: description);
      await loadProviders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Delete a provider
  Future<void> deleteProvider(int id) async {
    try {
      await _repository.deleteProvider(id);
      await loadProviders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Record last used timestamp
  Future<void> recordLastUsed(AiProvider provider) async {
    await _repository.updateLastUsed(provider);
  }
}
