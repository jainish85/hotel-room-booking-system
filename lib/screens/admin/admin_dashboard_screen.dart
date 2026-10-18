import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'admin_rooms_screen.dart';
import 'admin_users_screen.dart';
import 'admin_services_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';


class AdminDashboardScreen extends StatelessWidget {
  final UserModel user;

  const AdminDashboardScreen({
    super.key,
    required this.user,
  });

  Future<void> logout(BuildContext context) async {
    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await logout(context);
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user.name}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // User Management
              Card(
                child: ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('User Management'),
                  subtitle: const Text(
                    'Manage system users and roles',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminUsersScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Room Management
              Card(
                child: ListTile(
                  leading: const Icon(Icons.hotel),
                  title: const Text('Room Management'),
                  subtitle: const Text(
                    'Manage hotel rooms',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminRoomsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Booking Management
              Card(
                child: ListTile(
                  leading: const Icon(Icons.book_online),
                  title: const Text('Booking Management'),
                  subtitle: const Text(
                    'Manage all bookings',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const AdminBookingsScreen(),
                      ),
                    );
                  },                ),
              ),

              const SizedBox(height: 12),

              // Service Management
              Card(
                child: ListTile(
                  leading: const Icon(Icons.room_service),
                  title: const Text('Service Management'),
                  subtitle: const Text(
                    'Manage hotel services',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminServicesScreen(),
                      ),
                    );
                  },                ),
              ),

              const SizedBox(height: 12),

              // Reports
              Card(
                child: ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('Reports'),
                  subtitle: const Text(
                    'View hotel reports',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const AdminReportsScreen(),
                      ),
                    );
                  },                ),
              ),

              const SizedBox(height: 12),

              // System Settings
              Card(
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('System Settings'),
                  subtitle: const Text(
                    'Manage system settings',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const AdminSettingsScreen(),
                      ),
                    );
                  },                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}