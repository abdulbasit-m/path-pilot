import 'package:supabase_flutter/supabase_flutter.dart';
import 'roadmap_step_model.dart';

class RoadmapStepRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<RoadmapStep>> getStepsForRoadmap(String roadmapId) async {
    final response = await _supabase
        .from('roadmap_steps')
        .select()
        .eq('roadmap_id', roadmapId)
        .order('step_order', ascending: true);

    return (response as List<dynamic>)
        .map((json) => RoadmapStep.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createStep(Map<String, dynamic> data) async {
    await _supabase.from('roadmap_steps').insert(data);
  }

  Future<void> deleteStep(String id) async {
    await _supabase.from('roadmap_steps').delete().eq('id', id);
  }
}