import 'package:supabase_flutter/supabase_flutter.dart';
import 'roadmap_model.dart';

class RoadmapRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

 Future<List<Roadmap>> getRoadmapsForCareer(String careerFieldId) async {
    final response = await _supabase
        .from('roadmaps')
        .select()
        // .eq('career_field_id', careerFieldId)  <--- ADD THESE TWO SLASHES
        .eq('is_published', true)
        .order('created_at', ascending: true);
    
    return (response as List<dynamic>)
        .map((json) => Roadmap.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // --- NEW ADMIN METHODS ---
  Future<void> createRoadmap(Map<String, dynamic> data) async {
    await _supabase.from('roadmaps').insert(data);
  }

  Future<void> deleteRoadmap(String id) async {
    await _supabase.from('roadmaps').delete().eq('id', id);
  }
}