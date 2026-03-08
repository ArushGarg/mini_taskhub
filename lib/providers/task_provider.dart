import 'package:flutter/material.dart';
import '../dashboard/task_model.dart';
import '../services/supabase_service.dart';

enum TaskStatus { idle, loading, loaded, error }

class TaskProvider extends ChangeNotifier {
  final _service = SupabaseService();
  List<Task> _tasks = [];
  TaskStatus status = TaskStatus.idle;
  String? errorMessage;

  List<Task> get tasks => _tasks;
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  Future<void> loadTasks() async {
    status = TaskStatus.loading;
    notifyListeners();
    try {
      _tasks = await _service.fetchTasks();
      status = TaskStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = TaskStatus.error;
    }
    notifyListeners();
  }

  Future<void> addTask(String title, String? description) async {
    final task = await _service.createTask(title, description);
    _tasks.insert(0, task);
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    await _service.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  Future<void> toggleTask(String taskId, bool current) async {
    final updated = await _service.toggleTask(taskId, !current);
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) _tasks[index] = updated;
    notifyListeners();
  }

  Future<void> editTask(String taskId, String title, String? description) async {
    final updated = await _service.updateTask(taskId, title, description);
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) _tasks[index] = updated;
    notifyListeners();
  }
}