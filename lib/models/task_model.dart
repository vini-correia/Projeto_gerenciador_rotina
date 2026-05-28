class Task {
  final String id;
  final String userId;
  final String title;
  final String description;
  final bool isCompleted;
  final String category;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.category,
    this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      category: json['category'] ?? 'Geral',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'category': category,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}