import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final int completedTasks;
  final int totalTasks;

  const ProfileScreen({
    super.key,
    required this.onLogout,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final email = authProvider.user?.email ?? "User";
    final name = email.split('@').first;
    final displayName = "${name[0].toUpperCase()}${name.substring(1)}";
    final totalTasks = widget.totalTasks;
    final completedTasks = widget.completedTasks;
    final double completionPercentage = totalTasks == 0
        ? 0
        : (completedTasks / totalTasks);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {}, // Handled by bottom nav tap if we want to go back
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Avatar & Info
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    width: 100.w,
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF3D3CFA),
                                        width: 3.w,
                                      ),
                                      color: isDarkMode
                                          ? const Color(0xFF2C2C2C)
                                          : const Color(0xFFE4E7EC),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 50.sp,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : const Color(0xFF98A2B3),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -10,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3D3CFA),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Text(
                                        "ELITE\nMEMBER",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 2),

                        // Performance Summary
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x05000000),
                                blurRadius: 10.r,
                                offset: Offset(0.w, 4.h),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Performance Summary",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Row(
                                children: [
                                  // Circular Progress
                                  SizedBox(
                                    width: 100.w,
                                    height: 100.h,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CircularProgressIndicator(
                                          value: completionPercentage,
                                          strokeWidth: 10,
                                          backgroundColor: isDarkMode
                                              ? const Color(0xFF2C2C2C)
                                              : const Color(0xFFE5E5FF),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Color(0xFF3D3CFA)),
                                        ),
                                        Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${(completionPercentage * 100).toInt()}%",
                                                style: TextStyle(
                                                  fontSize: 22.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                ),
                                              ),
                                              Text(
                                                "DONE",
                                                style: TextStyle(
                                                  fontSize: 9.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF98A2B3),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 24.w),

                                  // Stats
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Tasks Completed",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF667085),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          "$completedTasks / $totalTasks",
                                          style: TextStyle(
                                            fontSize: 28.sp,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF3D3CFA),
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
                        const Spacer(flex: 2),

                        // App Settings
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "App Settings",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x05000000),
                                blurRadius: 10.r,
                                offset: Offset(0.w, 4.h),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildListTile(
                                context: context,
                                icon: Icons.notifications_rounded,
                                title: "Notifications",
                                trailing: Switch(
                                  value: _notificationsEnabled,
                                  onChanged: (v) {
                                    setState(() {
                                      _notificationsEnabled = v;
                                    });
                                  },
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: const Color(0xFF3D3CFA),
                                ),
                              ),
                              Divider(
                                color: isDarkMode
                                    ? Colors.white12
                                    : const Color(0xFFEAECF0),
                                height: 1.h,
                                indent: 16,
                                endIndent: 16,
                              ),
                              _buildListTile(
                                context: context,
                                icon: Icons.dark_mode_rounded,
                                title: "Dark Mode",
                                trailing: Switch(
                                  value: isDarkMode,
                                  onChanged: (v) {
                                    themeProvider.toggleTheme();
                                  },
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: const Color(0xFF3D3CFA),
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: const Color(0xFFD0D5DD),
                                ),
                              ),
                              Divider(
                                color: isDarkMode
                                    ? Colors.white12
                                    : const Color(0xFFEAECF0),
                                height: 1.h,
                                indent: 16,
                                endIndent: 16,
                              ),
                              _buildListTile(
                                context: context,
                                icon: Icons.logout_rounded,
                                iconColor: const Color(0xFFE93544),
                                title: "Sign Out",
                                titleColor: const Color(0xFFE93544),
                                onTap: widget.onLogout,
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFFD0D5DD),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? titleColor,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 8.h,
      ),
      leading: Icon(icon, color: iconColor ?? const Color(0xFF667085)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
