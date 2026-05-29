import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../models/finance_transaction.dart';
import '../models/exercise_model.dart';
import '../models/study_model.dart';

class DatabaseService {
  final _supabase = Supabase.instance.client;

  Future<List<Task>> getTasks(String userId) async {
    final response = await _supabase.from('tasks').select().eq('user_id', userId).order('created_at');
    return response.map((task) => Task.fromJson(task)).toList();
  }

  Future<void> addTask(Task task) async {
    await _supabase.from('tasks').insert(task.toJson());
  }

  Future<void> updateTaskStatus(String id, bool isCompleted) async {
    await _supabase.from('tasks').update({'is_completed': isCompleted}).eq('id', id);
  }

  Future<void> updateTask(Task task) async {
    await _supabase.from('tasks').update(task.toJson()).eq('id', task.id);
  }

  Future<void> deleteTask(String id) async {
    await _supabase.from('tasks').delete().eq('id', id);
  }

  Future<List<FinanceTransaction>> getTransactions(String userId) async {
    final response = await _supabase.from('transactions').select().eq('user_id', userId).order('date', ascending: false);
    return response.map((tx) => FinanceTransaction.fromJson(tx)).toList();
  }

  Future<void> addTransaction(FinanceTransaction transaction) async {
    await _supabase.from('transactions').insert(transaction.toJson());
  }

  Future<void> updateTransaction(FinanceTransaction transaction) async {
    await _supabase.from('transactions').update(transaction.toJson()).eq('id', transaction.id);
  }

  Future<void> deleteTransaction(String id) async {
    await _supabase.from('transactions').delete().eq('id', id);
  }

  Future<List<Exercise>> getExercises(String userId) async {
    final response = await _supabase.from('exercises').select().eq('user_id', userId).order('created_at');
    return response.map((ex) => Exercise.fromJson(ex)).toList();
  }

  Future<void> addExercise(Exercise exercise) async {
    await _supabase.from('exercises').insert(exercise.toJson());
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _supabase.from('exercises').update(exercise.toJson()).eq('id', exercise.id);
  }

  Future<void> deleteExercise(String id) async {
    await _supabase.from('exercises').delete().eq('id', id);
  }

  Future<List<Study>> getStudies(String userId) async {
    final response = await _supabase.from('studies').select().eq('user_id', userId).order('created_at');
    return response.map((study) => Study.fromJson(study)).toList();
  }

  Future<void> addStudy(Study study) async {
    await _supabase.from('studies').insert(study.toJson());
  }

  Future<void> updateStudy(Study study) async {
    await _supabase.from('studies').update(study.toJson()).eq('id', study.id);
  }

  Future<void> updateStudyProgress(String id, int progress) async {
    await _supabase.from('studies').update({'progress': progress}).eq('id', id);
  }

  Future<void> deleteStudy(String id) async {
    await _supabase.from('studies').delete().eq('id', id);
  }
}