class RoadmapStep {
  final String id;
  final String roadmapId;
  final String title;
  final String? description;
  final int stepOrder;
  final int estimatedHours;

  RoadmapStep({
    required this.id,
    required this.roadmapId,
    required this.title,
    this.description,
    required this.stepOrder,
    required this.estimatedHours,
  });

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      id: json['id'] as String,
      roadmapId: json['roadmap_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      stepOrder: json['step_order'] as int? ?? 0,
      estimatedHours: json['estimated_hours'] as int? ?? 0,
    );
  }
}