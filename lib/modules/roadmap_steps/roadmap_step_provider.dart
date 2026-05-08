import 'package:flutter/material.dart';
import 'roadmap_step_model.dart';
import 'roadmap_step_repository.dart';

class RoadmapStepProvider extends ChangeNotifier {
  final RoadmapStepRepository _repository = RoadmapStepRepository();
  List<RoadmapStep> _steps = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RoadmapStep> get steps => _steps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSteps(String roadmapId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _steps = await _repository.getStepsForRoadmap(roadmapId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStep(String roadmapId, String title, String description, int order, int hours) async {
    try {
      await _repository.createStep({
        'roadmap_id': roadmapId,
        'title': title,
        'description': description,
        'step_order': order,
        'estimated_hours': hours,
      });
      await fetchSteps(roadmapId); 
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStep(String id, String roadmapId) async {
    try {
      await _repository.deleteStep(id);
      await fetchSteps(roadmapId); 
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}