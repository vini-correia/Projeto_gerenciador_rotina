import 'package:flutter/material.dart';
import '../models/study_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/custom_text_field.dart';

class StudiesPage extends StatefulWidget {
  const StudiesPage({super.key});

  @override
  State<StudiesPage> createState() => _StudiesPageState();
}

class _StudiesPageState extends State<StudiesPage> {
  final _authService = AuthService();
  final _dbService = DatabaseService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late String _userId;
  String _selectedCategory = 'Programação';
  DateTime? _selectedDate;

  final List<String> _categories = [
    'Faculdade',
    'Programação',
    'Idiomas',
    'Projetos',
    'Outros'
  ];

  @override
  void initState() {
    super.initState();
    _userId = _authService.currentUser!.id;
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _showAddStudyDialog([Study? studyToEdit]) {
    if (studyToEdit != null) {
      _titleController.text = studyToEdit.title;
      _descController.text = studyToEdit.description;
      _selectedCategory = studyToEdit.category;
      _selectedDate = studyToEdit.estimatedCompletion;
    } else {
      _titleController.clear();
      _descController.clear();
      _selectedCategory = 'Programação';
      _selectedDate = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text(studyToEdit == null ? 'Novo Objetivo' : 'Editar Objetivo'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(controller: _titleController, label: 'Nome do Curso/Projeto'),
                      CustomTextField(controller: _descController, label: 'Descrição (Opcional)'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Categoria',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(value: category, child: Text(category));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setDialogState(() => _selectedCategory = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) setDialogState(() => _selectedDate = pickedDate);
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(_selectedDate == null
                            ? 'Conclusão Estimada'
                            : 'Data: ${_formatDate(_selectedDate!)}'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                  ElevatedButton(
                    onPressed: () async {
                      if (_titleController.text.trim().isNotEmpty) {
                        final study = Study(
                          id: studyToEdit?.id ?? '',
                          userId: _userId,
                          title: _titleController.text.trim(),
                          description: _descController.text.trim(),
                          category: _selectedCategory,
                          progress: studyToEdit?.progress ?? 0,
                          estimatedCompletion: _selectedDate,
                        );

                        if (studyToEdit == null) {
                          await _dbService.addStudy(study);
                        } else {
                          await _dbService.updateStudy(study);
                        }

                        if (mounted) {
                          Navigator.pop(context);
                          setState(() {});
                        }
                      }
                    },
                    child: Text(studyToEdit == null ? 'Adicionar' : 'Atualizar'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Faculdade': return Icons.school;
      case 'Programação': return Icons.code;
      case 'Idiomas': return Icons.language;
      case 'Projetos': return Icons.rocket_launch;
      default: return Icons.book;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Faculdade': return Colors.indigo;
      case 'Programação': return Colors.blueGrey;
      case 'Idiomas': return Colors.deepOrange;
      case 'Projetos': return Colors.teal;
      default: return Colors.blue;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<Study>>(
        future: _dbService.getStudies(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final studies = snapshot.data ?? [];
          if (studies.isEmpty) {
            return const Center(child: Text('Nenhum objetivo cadastrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: studies.length,
            itemBuilder: (context, index) {
              final study = studies[index];
              final catColor = _getCategoryColor(study.category);

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: catColor.withOpacity(0.1),
                                  child: Icon(_getCategoryIcon(study.category), color: catColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(study.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      if (study.description.isNotEmpty)
                                        Text(study.description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                onPressed: () => _showAddStudyDialog(study),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  await _dbService.deleteStudy(study.id);
                                  setState(() {});
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (study.estimatedCompletion != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                "Meta: ${_formatDate(study.estimatedCompletion!)}",
                                style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Progresso', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('${study.progress}%', style: TextStyle(color: catColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Slider(
                        value: study.progress.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        activeColor: catColor,
                        onChanged: (value) async {
                          await _dbService.updateStudyProgress(study.id, value.toInt());
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudyDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Objetivo'),
      ),
    );
  }
}