import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/custom_text_field.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _authService = AuthService();
  final _dbService = DatabaseService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late String _userId;
  String _selectedCategory = 'Geral';
  DateTime? _selectedDate;

  final List<String> _categories = [
    'Geral',
    'Trabalho',
    'Faculdade',
    'Inglês',
    'Treino',
    'Finanças'
  ];

  @override
  void initState() {
    super.initState();
    _userId = _authService.currentUser!.id;
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _showTaskDialog([Task? taskToEdit]) {
    if (taskToEdit != null) {
      _titleController.text = taskToEdit.title;
      _descController.text = taskToEdit.description;
      _selectedCategory = taskToEdit.category;
      _selectedDate = taskToEdit.dueDate;
    } else {
      _titleController.clear();
      _descController.clear();
      _selectedCategory = 'Geral';
      _selectedDate = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text(taskToEdit == null ? 'Novo Compromisso' : 'Editar Compromisso'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(controller: _titleController, label: 'Título'),
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
                          if (value != null) {
                            setDialogState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setDialogState(() => _selectedDate = pickedDate);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_selectedDate == null
                            ? 'Definir Prazo'
                            : 'Prazo: ${_formatDate(_selectedDate!)}'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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
                      if (_titleController.text.trim().isNotEmpty) {
                        final task = Task(
                          id: taskToEdit?.id ?? '',
                          userId: _userId,
                          title: _titleController.text.trim(),
                          description: _descController.text.trim(),
                          isCompleted: taskToEdit?.isCompleted ?? false,
                          category: _selectedCategory,
                          dueDate: _selectedDate,
                        );

                        if (taskToEdit == null) {
                          await _dbService.addTask(task);
                        } else {
                          await _dbService.updateTask(task);
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
                    child: Text(taskToEdit == null ? 'Salvar' : 'Atualizar'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Trabalho': return Colors.blueGrey;
      case 'Faculdade': return Colors.indigo;
      case 'Inglês': return Colors.deepOrange;
      case 'Treino': return Colors.teal;
      case 'Finanças': return Colors.green;
      default: return Colors.grey;
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
      body: FutureBuilder<List<Task>>(
        future: _dbService.getTasks(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar agenda.'));
          }
          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum compromisso pendente.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        value: task.isCompleted,
                        onChanged: (value) async {
                          if (value != null) {
                            await _dbService.updateTaskStatus(task.id, value);
                            setState(() {});
                          }
                        },
                      ),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: task.isCompleted ? Colors.grey : Colors.black87,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(task.category).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                task.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getCategoryColor(task.category),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (task.dueDate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: task.isCompleted ? Colors.grey.shade100 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: task.isCompleted ? Colors.grey : Colors.red.shade700
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(task.dueDate!),
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: task.isCompleted ? Colors.grey : Colors.red.shade700
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                          onPressed: () => _showTaskDialog(task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            await _dbService.deleteTask(task.id);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Tarefa'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}