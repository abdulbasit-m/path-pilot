class Career {
  final String id;
  final String title;
  final String? description;
  final String iconName;
  final String hexColor;

  Career({
    required this.id,
    required this.title,
    this.description,
    required this.iconName,
    required this.hexColor,
  });

  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String? ?? 'work',
      hexColor: json['hex_color'] as String? ?? '#0D9488',
    );
  }
}