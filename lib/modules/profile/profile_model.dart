class UserProfile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String role;
  final List<String> interests;

  UserProfile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.bio,
    required this.role,
    required this.interests,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String? ?? 'user',
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'role': role,
      'interests': interests,
    };
  }
}