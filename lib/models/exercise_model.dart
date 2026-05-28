class Exercise {
  final String id;
  final String userId;
  final String muscleGroup;
  final String name;
  final int sets;
  final String reps;
  final String weight;

  Exercise({
    required this.id,
    required this.userId,
    required this.muscleGroup,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      userId: json['user_id'],
      muscleGroup: json['muscle_group'],
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'muscle_group': muscleGroup,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }
}