import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';
import 'add_edit_task_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // Header section
                      _buildHeader(authProvider, todayPending),

                      // Task list
                      Expanded(
                        child:
                            taskProvider.isLoading && taskProvider.tasks.isEmpty
                            ? Center(
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
                                        padding: EdgeInsets.only(
                                          top: 8.h,
                                          bottom: 100.h,
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
              margin: EdgeInsets.only(bottom: 20.h),
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
                child: Icon(
                  Icons.add_rounded,
                  size: 32.sp,
                  color: Colors.white,
                ),
              ),
            ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D3CFA).withAlpha(20),
              blurRadius: 20.r,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
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
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E5FF),
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Icon(
                      Icons.dashboard_rounded,
                      color: Color(0xFF3D3CFA),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF475467),
                size: 28.sp,
              ),
            ],
          ),
          SizedBox(height: 32.h),

          // Greeting Text
          Text(
            "Hello, $displayName!",
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16.sp, color: Color(0xFF667085)),
              children: [
                const TextSpan(text: "You have "),
                TextSpan(
                  text: "$pending tasks",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3D3CFA),
                  ),
                ),
                const TextSpan(text: " remaining today"),
              ],
            ),
          ),
          SizedBox(height: 40.h),

          // Today's Tasks Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showAllTasks ? "All Tasks" : "Today's Tasks",
                style: TextStyle(
                  fontSize: 18.sp,
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
                  style: TextStyle(
                    fontSize: 14.sp,
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
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  size: 50.sp,
                  color: AppColors.primaryLight,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "No tasks yet!",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Tap the + button to create\nyour first task",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textLight,
                  height: 1.5.h,
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
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFF667085), // Slate grey instead of red
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 26.sp,
        ),
      ),
      onDismissed: (direction) {
        taskProvider.deleteTask(authProvider.user!.uid, task.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Task deleted"),
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
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withAlpha(12),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 10.r,
              offset: Offset(0.w, 4.h),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(20.w),
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
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? const Color(0xFF6F6FFF)
                            : Colors.transparent,
                        border: task.isCompleted
                            ? null
                            : Border.all(
                                color: const Color(0xFFD0D5DD),
                                width: 1.5.w,
                              ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: task.isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              size: 16.sp,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Task details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16.sp,
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
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: pillBg,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                pillLabel,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: pillText,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "${task.dueDate.day.toString().padLeft(2, '0')}/${task.dueDate.month.toString().padLeft(2, '0')}/${task.dueDate.year}",
                              style: TextStyle(
                                fontSize: 12.sp,
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
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Color(0xFF98A2B3),
                      size: 24.sp,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
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
                            content: Text("Task deleted"),
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
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20.sp,
                              color: Color(0xFF344054),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF344054),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 20.sp,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 14.sp,
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
