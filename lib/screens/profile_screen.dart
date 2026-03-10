import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
// Task provider unused import removed

class ProfileScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final email = authProvider.user?.email ?? "User";
    final name = email.split('@').first;
    final displayName = "${name[0].toUpperCase()}${name.substring(1)}";
    final double completionPercentage = totalTasks == 0
        ? 0
        : (completedTasks / totalTasks);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF101928)),
          onPressed: () {}, // Handled by bottom nav tap if we want to go back
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF101928),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Color(0xFF101928)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF3D3CFA),
                            width: 3,
                          ),
                          color: const Color(0xFFE4E7EC),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: Color(0xFF98A2B3),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D3CFA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "ELITE\nMEMBER",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101928),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Product Strategist & High Achiever",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Performance Summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Performance Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101928),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // Circular Progress
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: completionPercentage,
                              strokeWidth: 10,
                              backgroundColor: const Color(0xFFE5E5FF),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF3D3CFA),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${(completionPercentage * 100).toInt()}%",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF101928),
                                    ),
                                  ),
                                  const Text(
                                    "DONE",
                                    style: TextStyle(
                                      fontSize: 9,
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
                      const SizedBox(width: 24),

                      // Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tasks Completed",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$completedTasks / $totalTasks",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3D3CFA),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 1,
                              color: const Color(0xFFEAECF0),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Weekly Streak",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Text(
                                  "12 Days ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF101928),
                                  ),
                                ),
                                Text("🔥", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // App Settings
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "App Settings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101928),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.notifications_rounded,
                    title: "Notifications",
                    trailing: Switch(
                      value: true,
                      onChanged: (v) {},
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF3D3CFA),
                    ),
                  ),
                  const Divider(
                    color: Color(0xFFEAECF0),
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  _buildListTile(
                    icon: Icons.dark_mode_rounded,
                    title: "Dark Mode",
                    trailing: Switch(
                      value: false,
                      onChanged: (v) {},
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFD0D5DD),
                    ),
                  ),
                  const Divider(
                    color: Color(0xFFEAECF0),
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  _buildListTile(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFE93544),
                    title: "Sign Out",
                    titleColor: const Color(0xFFE93544),
                    onTap: onLogout,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFD0D5DD),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? titleColor,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Icon(icon, color: iconColor ?? const Color(0xFF667085)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: titleColor ?? const Color(0xFF101928),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
