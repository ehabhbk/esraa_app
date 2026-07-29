import 'package:flutter/foundation.dart';
import '../models/my_idea.dart';
import '../services/database_service.dart';

class IdeaProvider extends ChangeNotifier {
  List<MyIdea> _ideas = [];
  bool _isLoading = false;

  List<MyIdea> get ideas => _ideas;
  bool get isLoading => _isLoading;

  Future<void> loadIdeas() async {
    _isLoading = true;
    notifyListeners();
    try {
      final maps = await DatabaseService.query('my_ideas', orderBy: 'createdAt DESC');
      _ideas = maps.map((m) => MyIdea.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading ideas: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addIdea(MyIdea idea) async {
    await DatabaseService.insert('my_ideas', idea.toMap());
    await loadIdeas();
  }

  Future<void> updateIdea(MyIdea idea) async {
    await DatabaseService.update('my_ideas', idea.toMap(), 'id = ?', [idea.id]);
    await loadIdeas();
  }

  Future<void> deleteIdea(int id) async {
    await DatabaseService.delete('my_ideas', 'id = ?', [id]);
    await loadIdeas();
  }
}
