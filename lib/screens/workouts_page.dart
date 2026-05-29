import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/custom_text_field.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  final _authService = AuthService();
  final _dbService = DatabaseService();

  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  late String _userId;

  final List<Map<String, dynamic>> _muscleGroups = [
    {'name': 'Peito', 'icon': Icons.fitness_center, 'color': Colors.blue},
    {'name': 'Costas', 'icon': Icons.accessibility_new, 'color': Colors.indigo},
    {'name': 'Pernas', 'icon': Icons.directions_run, 'color': Colors.green},
    {'name': 'Ombros', 'icon': Icons.accessibility, 'color': Colors.orange},
    {'name': 'Bíceps', 'icon': Icons.pan_tool, 'color': Colors.teal},
    {'name': 'Tríceps', 'icon': Icons.back_hand, 'color': Colors.red},
    {'name': 'Abdômen', 'icon': Icons.view_compact, 'color': Colors.deepPurple},
  ];

  @override
  void initState() {
    super.initState();
    _userId = _authService.currentUser!.id;
  }

  void _showAddExerciseDialog(String muscleGroup, [Exercise? exToEdit]) {
    if (exToEdit != null) {
      _nameController.text = exToEdit.name;
      _setsController.text = exToEdit.sets.toString();
      _repsController.text = exToEdit.reps;
      _weightController.text = exToEdit.weight;
    } else {
      _nameController.clear();
      _setsController.text = '3';
      _repsController.text = '10 a 12';
      _weightController.text = '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(exToEdit == null ? 'Novo Exercício: $muscleGroup' : 'Editar Exercício'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                    controller: _nameController,
                    label: 'Nome do Exercício'
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _setsController,
                        label: 'Séries',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _repsController,
                        label: 'Repetições',
                      ),
                    ),
                  ],
                ),
                CustomTextField(
                    controller: _weightController,
                    label: 'Carga (Opcional)'
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isNotEmpty && _setsController.text.trim().isNotEmpty) {
                  final exercise = Exercise(
                    id: exToEdit?.id ?? '',
                    userId: _userId,
                    muscleGroup: muscleGroup,
                    name: _nameController.text.trim(),
                    sets: int.tryParse(_setsController.text.trim()) ?? 3,
                    reps: _repsController.text.trim(),
                    weight: _weightController.text.trim(),
                  );

                  if (exToEdit == null) {
                    await _dbService.addExercise(exercise);
                  } else {
                    await _dbService.updateExercise(exercise);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {});
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(exToEdit == null ? 'Adicionar' : 'Atualizar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<Exercise>>(
        future: _dbService.getExercises(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar treinos.'));
          }

          final exercises = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _muscleGroups.length,
            itemBuilder: (context, index) {
              final group = _muscleGroups[index];
              final groupName = group['name'] as String;
              final groupColor = group['color'] as Color;
              final groupIcon = group['icon'] as IconData;

              final groupExercises = exercises.where((e) => e.muscleGroup == groupName).toList();

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: groupColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(groupIcon, color: groupColor),
                              const SizedBox(width: 8),
                              Text(
                                groupName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: groupColor,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: groupColor),
                            onPressed: () => _showAddExerciseDialog(groupName),
                            tooltip: 'Adicionar exercício',
                          ),
                        ],
                      ),
                    ),
                    if (groupExercises.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Nenhum exercício cadastrado.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: groupExercises.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                        itemBuilder: (context, idx) {
                          final ex = groupExercises[idx];
                          return ListTile(
                            title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${ex.sets} séries x ${ex.reps} | Carga: ${ex.weight}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                  onPressed: () => _showAddExerciseDialog(groupName, ex),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    await _dbService.deleteExercise(ex.id);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}