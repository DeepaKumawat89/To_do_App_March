import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? "",
    );
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final userId = authProvider.user!.uid;

      if (widget.task == null) {
        // Create new task
        final newTask = Task(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          createdAt: DateTime.now(),
        );
        await taskProvider.addTask(userId, newTask);
      } else {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
        );
        await taskProvider.updateTask(userId, updatedTask);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final isEditing = widget.task != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                  Text(
                    isEditing ? "Edit Task" : "New Task",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 42), // Balance spacer
                ],
              ),
            ),

            // Form body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),

                      // Title label
                      const Text(
                        "Title",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _titleController,
                        label: "What needs to be done?",
                        icon: Icons.edit_rounded,
                        validator: (v) =>
                            v!.isEmpty ? "Title is required" : null,
                      ),
                      const SizedBox(height: 24),

                      // Description label
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _descriptionController,
                        label: "Add some details (optional)",
                        icon: Icons.notes_rounded,
                        maxLines: 4,
                      ),
                      const Spacer(),

                      // Save button
                      CustomButton(
                        text: isEditing ? "Update Task" : "Create Task",
                        isLoading: taskProvider.isLoading,
                        onPressed: _saveTask,
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
