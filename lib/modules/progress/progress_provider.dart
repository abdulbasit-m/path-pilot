import 'package:flutter/material.dart';
import 'progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _repository = ProgressRepository();
  Set<String> _completedStepIds = {};
  bool _isLoading = false;

  Set<String> get completedStepIds => _completedStepIds;
  bool get isLoading => _isLoading;

  Future<void> fetchProgress() async {
    _isLoading = true;
    notifyListeners();

    try {
      final ids = await _repository.getCompletedSteps();
      _completedStepIds = ids.toSet();
    } catch (e) {
      debugPrint('Error fetching progress: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isStepCompleted(String stepId) {
    return _completedStepIds.contains(stepId);
  }

  Future<void> toggleStepCompletion(String stepId) async {
    final currentlyCompleted = isStepCompleted(stepId);
    
    // Optimistic UI update for instant feedback
    if (currentlyCompleted) {
      _completedStepIds.remove(stepId);
    } else {
      _completedStepIds.add(stepId);
    }
    notifyListeners();

    try {
      if (currentlyCompleted) {
        await _repository.markStepIncomplete(stepId);
      } else {
        await _repository.markStepComplete(stepId);
      }
    } catch (e) {
      // Revert if database fails
      if (currentlyCompleted) {
        _completedStepIds.add(stepId);
      } else {
        _completedStepIds.remove(stepId);
      }
      notifyListeners();
      debugPrint('Error toggling progress: $e');
    }
  }
}