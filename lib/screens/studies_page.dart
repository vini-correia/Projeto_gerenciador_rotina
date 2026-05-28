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

  void _showAddStudyDialog() {
    _titleController.clear();
    _descController.clear();
    _selectedCategory = 'Programação';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Novo Objetivo de Estudo'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(controller: _titleController, label: 'Nome do Curso/Projeto'),
                      CustomTextField(controller: _descController, label: 'Descrição (Ex: Módulo 1)'),
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
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                  ElevatedButton(
                    onPressed: () async {
                      if (_titleController.text.trim().isNotEmpty) {
                        final study = Study(
                          id: '',
                          userId: _userId,
                          title: _titleController.text.trim(),
                          description: _descController.text.trim(),
                          category: _selectedCategory,
                          progress: 0,
                        );
                        await _dbService.addStudy(study);
                        if (mounted) {
                          Navigator.pop(context);
                          setState(() {});
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Adicionar'),
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
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar estudos.'));
          }

          final studies = snapshot.data ?? [];

          if (studies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum curso ou projeto cadastrado.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
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
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: catColor.withOpacity(0.1),
                                child: Icon(_getCategoryIcon(study.category), color: catColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    study.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  if (study.description.isNotEmpty)
                                    Text(
                                      study.description,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              await _dbService.deleteStudy(study.id);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Progresso', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('${study.progress}%', style: TextStyle(color: catColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: study.progress.toDouble(),
                              min: 0,
                              max: 100,
                              divisions: 20,
                              activeColor: catColor,
                              inactiveColor: catColor.withOpacity(0.2),
                              label: '${study.progress}%',
                              onChanged: (value) async {
                                await _dbService.updateStudyProgress(study.id, value.toInt());
                                setState(() {});
                              },
                            ),
                          ),
                          if (study.progress == 100)
                            const Icon(Icons.emoji_events, color: Colors.amber),
                        ],
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
        onPressed: _showAddStudyDialog,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}