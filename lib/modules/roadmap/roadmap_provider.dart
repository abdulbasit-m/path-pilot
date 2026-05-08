import 'package:flutter/material.dart';
import 'roadmap_model.dart';
import 'roadmap_repository.dart';

class RoadmapProvider extends ChangeNotifier {
  final RoadmapRepository _repository = RoadmapRepository();
  List<Roadmap> _roadmaps = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Roadmap> get roadmaps => _roadmaps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRoadmaps(String careerFieldId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _roadmaps = await _repository.getRoadmapsForCareer(careerFieldId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- NEW ADMIN METHODS ---
  Future<bool> addRoadmap(String careerFieldId, String title, String description, String difficulty, int hours) async {
    try {
      await _repository.createRoadmap({
        'career_field_id': careerFieldId,
        'title': title,
        'description': description,
        'difficulty_level': difficulty,
        'estimated_hours': hours,
        'is_published': true, // Auto-publishing for simplicity
      });
      await fetchRoadmaps(careerFieldId); // Refresh the list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoadmap(String id, String careerFieldId) async {
    try {
      await _repository.deleteRoadmap(id);
      await fetchRoadmaps(careerFieldId); // Refresh the list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}