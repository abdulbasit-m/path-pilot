import 'package:supabase_flutter/supabase_flutter.dart';
import 'resource_model.dart';

class ResourceRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Resource>> getResourcesForStep(String stepId) async {
    final response = await _supabase
        .from('resources')
        .select()
        .eq('step_id', stepId)
        .order('created_at', ascending: true);

    return (response as List<dynamic>)
        .map((json) => Resource.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // --- NEW ADMIN METHODS ---
  Future<void> createResource(Map<String, dynamic> data) async {
    await _supabase.from('resources').insert(data);
  }

  Future<void> deleteResource(String id) async {
    await _supabase.from('resources').delete().eq('id', id);
  }
}