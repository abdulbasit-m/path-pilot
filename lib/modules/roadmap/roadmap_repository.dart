import 'package:supabase_flutter/supabase_flutter.dart';
import 'roadmap_model.dart';

class RoadmapRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetches roadmaps strictly filtered by the clicked career
  Future<List<Roadmap>> getRoadmapsForCareer(String careerFieldId) async {
    final response = await _supabase
        .from('roadmaps')
        .select('*')
        .eq('career_field_id', careerFieldId);

    return (response as List).map((json) => Roadmap.fromJson(json)).toList();
  }

  // Admin: Creates a new roadmap
  Future<void> createRoadmap(Map<String, dynamic> data) async {
    await _supabase.from('roadmaps').insert(data);
  }

  // Admin: Deletes a roadmap
  Future<void> deleteRoadmap(String id) async {
    await _supabase.from('roadmaps').delete().eq('id', id);
  }
}