class Study {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final int progress;

  Study({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.progress,
  });

  factory Study.fromJson(Map<String, dynamic> json) {
    return Study(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'] ?? 'Outros',
      progress: json['progress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'progress': progress,
    };
  }
}