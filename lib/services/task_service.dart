import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Helper to get user's task collection
  CollectionReference<Map<String, dynamic>> _userTasks(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Fetch all tasks for a user
  Future<List<Task>> getTasks(String userId) async {
    try {
      final querySnapshot = await _userTasks(
        userId,
      ).orderBy('createdAt', descending: true).get();

      return querySnapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      _logger.e("GetTasks Error: $e");
      rethrow;
    }
  }

  // Add a new task
  Future<Task> addTask(String userId, Task task) async {
    try {
      final docRef = await _userTasks(userId).add(task.toMap());
      return task.copyWith(id: docRef.id);
    } catch (e) {
      _logger.e("AddTask Error: $e");
      rethrow;
    }
  }

  // Update an existing task
  Future<void> updateTask(String userId, Task task) async {
    if (task.id == null) return;

    try {
      await _userTasks(userId).doc(task.id).update(task.toMap());
    } catch (e) {
      _logger.e("UpdateTask Error: $e");
      rethrow;
    }
  }

  // Delete a task
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _userTasks(userId).doc(taskId).delete();
    } catch (e) {
      _logger.e("DeleteTask Error: $e");
      rethrow;
    }
  }

  // Stream for real-time updates (Bonus)
  Stream<List<Task>> taskStream(String userId) {
    return _userTasks(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}
