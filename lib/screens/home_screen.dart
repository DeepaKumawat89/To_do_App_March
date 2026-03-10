import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    // Count completed & pending
    final completed = taskProvider.tasks.where((t) => t.isCompleted).length;
    final pending = taskProvider.tasks.length - completed;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: _currentIndex == 3
          ? ProfileScreen(
              onLogout: _logout,
              completedTasks: completed,
              totalTasks: taskProvider.tasks.length,
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // Header section
                      _buildHeader(
                        authProvider,
                        taskProvider.tasks.length,
                        completed,
                        pending,
                      ),

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
                                child: taskProvider.tasks.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.builder(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 100,
                                        ),
                                        itemCount: taskProvider.tasks.length,
                                        itemBuilder: (context, index) {
                                          final task =
                                              taskProvider.tasks[index];
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
      floatingActionButton: _currentIndex == 3
          ? null
          : Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3D3CFA).withOpacity(0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
                borderRadius: BorderRadius.circular(30),
              ),
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
                backgroundColor: const Color(0xFF3D3CFA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3D3CFA),
        unselectedItemColor: const Color(0xFF98A2B3),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.home_filled, size: 26),
            ),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.check_circle_outline_rounded, size: 26),
            ),
            label: 'TASKS',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.calendar_today_outlined, size: 24),
            ),
            label: 'SCHEDULE',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.person_outline_rounded, size: 28),
            ),
            label: 'PROFILE',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHeader(
    AuthProvider authProvider,
    int total,
    int completed,
    int pending,
  ) {
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
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101928),
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
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101928),
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
              const Text(
                "Today's Tasks",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101928),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "View all",
                  style: TextStyle(
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
    // Determine priority styling based on index for the UI matched mockup
    int tagIndex = index % 3;
    Color pillBg;
    Color pillText;
    String pillLabel;

    if (tagIndex == 0) {
      pillBg = const Color(0xFFFEEFC3); // Soft Amber for high priority
      pillText = const Color(0xFFB45309);
      pillLabel = "URGENT";
    } else if (tagIndex == 1) {
      pillBg = const Color(0xFFE5F0FF);
      pillText = const Color(0xFF1E6CFF);
      pillLabel = "MEDIUM";
    } else {
      pillBg = const Color(0xFFF2F4F7);
      pillText = const Color(0xFF667085);
      pillLabel = "LOW";
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF2F4F7), width: 1.5),
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
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddEditTaskScreen(task: task),
              );
            },
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
                                : const Color(0xFF101928),
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: const Color(0xFF98A2B3),
                          ),
                        ),
                        const SizedBox(height: 6),
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
                      ],
                    ),
                  ),

                  // 3 Dots
                  const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF98A2B3),
                    size: 24,
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
