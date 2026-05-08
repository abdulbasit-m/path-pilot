import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all completed step IDs for the logged-in user
  Future<List<String>> getCompletedSteps() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

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
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabase.from('user_progress').insert({
      'user_id': userId,
      'step_id': stepId,
    });
  }

  // Mark a step as incomplete
  Future<void> markStepIncomplete(String stepId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabase
        .from('user_progress')
        .delete()
        .eq('user_id', userId)
        .eq('step_id', stepId);
  }
}