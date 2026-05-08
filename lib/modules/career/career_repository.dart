import 'package:supabase_flutter/supabase_flutter.dart';
import 'career_model.dart';

class CareerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Career>> getCareers() async {
    final response = await _supabase
        .from('career_fields')
        .select()
        .order('title', ascending: true);
    
    return (response as List<dynamic>)
        .map((json) => Career.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createCareer(Map<String, dynamic> data) async {
    await _supabase.from('career_fields').insert(data);
  }

  Future<void> deleteCareer(String id) async {
    await _supabase.from('career_fields').delete().eq('id', id);
  }
}