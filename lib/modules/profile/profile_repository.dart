import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_model.dart';

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserProfile?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    if (response != null) {
      return UserProfile.fromJson(response);
    }
    return null;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _supabase.from('profiles').update({
      'full_name': profile.fullName,
      'bio': profile.bio,
      'avatar_url': profile.avatarUrl,
      'interests': profile.interests,
    }).eq('id', profile.id);
  }
}