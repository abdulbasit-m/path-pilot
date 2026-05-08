import 'package:flutter/material.dart';
import 'resource_model.dart';
import 'resource_repository.dart';

class ResourceProvider extends ChangeNotifier {
  final ResourceRepository _repository = ResourceRepository();
  List<Resource> _resources = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Resource> get resources => _resources;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchResources(String stepId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _resources = await _repository.getResourcesForStep(stepId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- NEW ADMIN METHODS ---
  Future<bool> addResource(String stepId, String title, String url, String type) async {
    try {
      await _repository.createResource({
        'step_id': stepId,
        'title': title,
        'url': url,
        'resource_type': type,
      });
      await fetchResources(stepId); // Refresh the list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteResource(String id, String stepId) async {
    try {
      await _repository.deleteResource(id);
      await fetchResources(stepId); // Refresh the list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}