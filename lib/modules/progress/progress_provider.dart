import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Set of completed step IDs for the logged-in user
  final Set<String> _completedStepIds = {};
  bool _isLoading = false;

  Set<String> get completedStepIds => _completedStepIds;
  bool get isLoading => _isLoading;

  // Fetch all completed steps for the current user
  Future<void> fetchProgress() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('user_progress')
          .select('step_id')
          .eq('user_id', user.id);

      _completedStepIds.clear();
      for (var row in response as List) {
        _completedStepIds.add(row['step_id'].toString());
      }
    } catch (e) {
      debugPrint('Error fetching progress: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle step completion status status
  Future<void> toggleStepCompletion(String stepId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final isCompleted = _completedStepIds.contains(stepId);

    try {
      if (isCompleted) {
        // Uncheck milestone
        _completedStepIds.remove(stepId);
        notifyListeners();
        
        await _supabase
            .from('user_progress')
            .delete()
            .eq('user_id', user.id)
            .eq('step_id', stepId);
      } else {
        // Check milestone
        _completedStepIds.add(stepId);
        notifyListeners();

        await _supabase.from('user_progress').insert({
          'user_id': user.id,
          'step_id': stepId,
        });
      }
    } catch (e) {
      // Rollback state if network request fails
      if (isCompleted) {
        _completedStepIds.add(stepId);
      } else {
        _completedStepIds.remove(stepId);
      }
      debugPrint('Error toggling progress: $e');
      notifyListeners();
    }
  }
}