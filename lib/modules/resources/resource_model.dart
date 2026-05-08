class Resource {
  final String id;
  final String stepId;
  final String title;
  final String url;
  final String resourceType;

  Resource({
    required this.id,
    required this.stepId,
    required this.title,
    required this.url,
    required this.resourceType,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      stepId: json['step_id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      resourceType: json['resource_type'] as String? ?? 'article',
    );
  }
}