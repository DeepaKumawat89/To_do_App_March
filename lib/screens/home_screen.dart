import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';
import 'add_edit_task_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showAllTasks = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTasks());
  }

  Future<void> _loadTasks() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (authProvider.user != null) {
      taskProvider.fetchTasks(authProvider.user!.uid);
    }
  }

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final today = DateTime.now();

    // Total stats for profile:
    final overallCompleted = taskProvider.tasks
        .where((t) => t.isCompleted)
        .length;

    // Tasks list filtering
    var displayedTasks = taskProvider.tasks;
    if (!_showAllTasks) {
      displayedTasks = displayedTasks
          .where(
            (t) =>
                t.dueDate.year == today.year &&
                t.dueDate.month == today.month &&
                t.dueDate.day == today.day,
          )
          .toList();
    }

    // Sort tasks by date
    displayedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    // today's pending
    int todayPending = taskProvider.tasks
        .where(
          (t) =>
              t.dueDate.year == today.year &&
              t.dueDate.month == today.month &&
              t.dueDate.day == today.day &&
              !t.isCompleted,
        )
        .length;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _currentIndex == 1
          ? ProfileScreen(
              onLogout: _logout,
              completedTasks: overallCompleted,
              totalTasks: taskProvider.tasks.length,
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // Header section
                      _buildHeader(authProvider, todayPending),

                      // Task list
                      Expanded(
                        child:
                            taskProvider.isLoading && taskProvider.tasks.isEmpty
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : RefreshIndicator(
                                color: AppColors.primary,
                                onRefresh: _loadTasks,
                                child: displayedTasks.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.builder(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 100,
                                        ),
                                        itemCount: displayedTasks.length,
                                        itemBuilder: (context, index) {
                                          final task = displayedTasks[index];
                                          return _buildTaskCard(
                                            task,
                                            taskProvider,
                                            authProvider,
                                            index,
                                          );
                                        },
                                      ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: _currentIndex == 1
          ? null
          : Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddEditTaskScreen(),
                  );
                },
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                backgroundColor: const Color(0xFF3D3CFA),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D3CFA).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: WaterDropNavBar(
            backgroundColor: Theme.of(context).cardColor,
            waterDropColor: const Color(0xFF3D3CFA),
            inactiveIconColor: const Color(0xFF98A2B3),
            iconSize: 32,
            bottomPadding: 16,
            onItemSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedIndex: _currentIndex,
            barItems: [
              BarItem(
                filledIcon: Icons.home_rounded,
                outlinedIcon: Icons.home_outlined,
              ),
              BarItem(
                filledIcon: Icons.person_rounded,
                outlinedIcon: Icons.person_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider authProvider, int pending) {
    final email = authProvider.user?.email ?? "User";
    final name = email.split('@').first;
    final displayName = "${name[0].toUpperCase()}${name.substring(1)}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E5FF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.dashboard_rounded,
                      color: Color(0xFF3D3CFA),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF475467),
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Greeting Text
          Text(
            "Hello, $displayName!",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Color(0xFF667085)),
              children: [
                const TextSpan(text: "You have "),
                TextSpan(
                  text: "$pending tasks",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3D3CFA),
                  ),
                ),
                const TextSpan(text: " remaining today"),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Today's Tasks Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showAllTasks ? "All Tasks" : "Today's Tasks",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllTasks = !_showAllTasks;
                  });
                },
                child: Text(
                  _showAllTasks ? "View Today" : "View all",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3D3CFA),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      // Needed for RefreshIndicator to work on empty list
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  size: 50,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "No tasks yet!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tap the + button to create\nyour first task",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(
    Task task,
    TaskProvider taskProvider,
    AuthProvider authProvider,
    int index,
  ) {
    Color pillBg;
    Color pillText;
    String pillLabel = task.priority.toUpperCase();

    if (task.priority == "High") {
      pillBg = const Color(0xFFFEEFC3); // Soft Amber for high priority
      pillText = const Color(0xFFB45309);
    } else if (task.priority == "Med") {
      pillBg = const Color(0xFFE5F0FF);
      pillText = const Color(0xFF1E6CFF);
      pillLabel = "MEDIUM";
    } else {
      pillBg = const Color(0xFFF2F4F7);
      pillText = const Color(0xFF667085);
    }

    return Dismissible(
      key: Key(task.id!),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF667085), // Slate grey instead of red
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      onDismissed: (direction) {
        taskProvider.deleteTask(authProvider.user!.uid, task.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Task deleted"),
              action: SnackBarAction(
                label: "UNDO",
                textColor: Colors.white,
                onPressed: () {
                  taskProvider.addTask(authProvider.user!.uid, task);
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.05),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () {
                      taskProvider.toggleTaskStatus(
                        authProvider.user!.uid,
                        task,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? const Color(0xFF6F6FFF)
                            : Colors.transparent,
                        border: task.isCompleted
                            ? null
                            : Border.all(
                                color: const Color(0xFFD0D5DD),
                                width: 1.5,
                              ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Task details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: task.isCompleted
                                ? const Color(0xFF98A2B3)
                                : Theme.of(context).colorScheme.onSurface,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: const Color(0xFF98A2B3),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: pillBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                pillLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: pillText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${task.dueDate.day.toString().padLeft(2, '0')}/${task.dueDate.month.toString().padLeft(2, '0')}/${task.dueDate.year}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF98A2B3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Options Menu
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Color(0xFF98A2B3),
                      size: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Theme.of(context).cardColor,
                    elevation: 4,
                    onSelected: (value) {
                      if (value == 'edit') {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AddEditTaskScreen(task: task),
                        );
                      } else if (value == 'delete') {
                        taskProvider.deleteTask(
                          authProvider.user!.uid,
                          task.id!,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Task deleted"),
                            action: SnackBarAction(
                              label: "UNDO",
                              textColor: Colors.white,
                              onPressed: () {
                                taskProvider.addTask(
                                  authProvider.user!.uid,
                                  task,
                                );
                              },
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Color(0xFF344054),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF344054),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
