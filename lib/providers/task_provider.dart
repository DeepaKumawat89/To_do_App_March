import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch tasks
  Future<void> fetchTasks(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add task
  Future<void> addTask(String userId, Task task) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newTask = await _taskService.addTask(userId, task);
      _tasks.insert(0, newTask);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update task
  Future<void> updateTask(String userId, Task task) async {
    try {
      await _taskService.updateTask(userId, task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Toggle completion
  Future<void> toggleTaskStatus(String userId, Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(userId, updatedTask);
  }

  // Delete task
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _taskService.deleteTask(userId, taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Bonus: Stream for real-time updates
  Stream<List<Task>> getTaskStream(String userId) {
    return _taskService.taskStream(userId);
  }
}
