class Roadmap {
  final String id;
  final String careerFieldId;
  final String title;
  final String? description;
  final String difficultyLevel;
  final int estimatedHours;

  Roadmap({
    required this.id,
    required this.careerFieldId,
    required this.title,
    this.description,
    required this.difficultyLevel,
    required this.estimatedHours,
  });

  factory Roadmap.fromJson(Map<String, dynamic> json) {
    return Roadmap(
      id: json['id'] as String,
      careerFieldId: json['career_field_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      difficultyLevel: json['difficulty_level'] as String? ?? 'beginner',
      estimatedHours: json['estimated_hours'] as int? ?? 0,
    );
  }
}