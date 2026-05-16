import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // A temporary mock UUID to bypass auth checks during development
  final String _mockUserId = '00000000-0000-0000-0000-000000000000';

  String _getEffectiveUserId() {
    return _supabase.auth.currentUser?.id ?? _mockUserId;
  }

  // Fetch all completed step IDs
  Future<List<String>> getCompletedSteps() async {
    final userId = _getEffectiveUserId();

    final response = await _supabase
        .from('user_progress')
        .select('step_id')
        .eq('user_id', userId);

    return (response as List<dynamic>)
        .map((row) => row['step_id'] as String)
        .toList();
  }

  // Mark a step as complete
  Future<void> markStepComplete(String stepId) async {
    final userId = _getEffectiveUserId();

    await _supabase.from('user_progress').insert({
      'user_id': userId,
      'step_id': stepId,
    });
  }

  // Mark a step as incomplete
  Future<void> markStepIncomplete(String stepId) async {
    final userId = _getEffectiveUserId();

    await _supabase
        .from('user_progress')
        .delete()
        .eq('user_id', userId)
        .eq('step_id', stepId);
  }
}