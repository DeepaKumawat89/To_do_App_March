import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final String priority;
  final DateTime dueDate;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.priority = "Low",
    required this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'priority': priority,
      'dueDate': dueDate,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    DateTime createdAtDate;
    if (map['createdAt'] is Timestamp) {
      createdAtDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      createdAtDate = DateTime.parse(map['createdAt']);
    } else {
      createdAtDate = DateTime.now();
    }

    DateTime dueDateDate;
    if (map['dueDate'] is Timestamp) {
      dueDateDate = (map['dueDate'] as Timestamp).toDate();
    } else if (map['dueDate'] is String) {
      dueDateDate = DateTime.parse(map['dueDate']);
    } else {
      dueDateDate = DateTime.now();
    }

    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: createdAtDate,
      priority: map['priority'] ?? 'Low',
      dueDate: dueDateDate,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    String? priority,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
