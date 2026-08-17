import 'package:flutter/foundation.dart';
import 'package:multiai_hub/data/models/models.dart';
import 'package:multiai_hub/data/repository/ai_repository.dart';

/// Notes screen ViewModel
class NotesViewModel extends ChangeNotifier {
  final AiRepository _repository = AiRepository();

  List<Note> _notes = [];
  bool _isLoading = true;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all notes
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notes = await _repository.getAllNotes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new note
  Future<void> addNote(String title, String content) async {
    try {
      await _repository.addNote(title, content);
      await loadNotes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update an existing note
  Future<void> updateNote(Note note) async {
    try {
      await _repository.updateNote(note);
      await loadNotes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Delete a note
  Future<void> deleteNote(int id) async {
    try {
      await _repository.deleteNote(id);
      await loadNotes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
