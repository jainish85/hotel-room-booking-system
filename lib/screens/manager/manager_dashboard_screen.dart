import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'manager_bookings_screen.dart';
import 'manager_customer_requests_screen.dart';
import 'manager_customers_screen.dart';
import 'manager_rooms_screen.dart';
import 'manager_service_requests_screen.dart';

class ManagerDashboardScreen extends StatelessWidget {
  final UserModel user;

  const ManagerDashboardScreen({
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
        title: const Text('Manager Dashboard'),
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
                        builder: (_) =>
                        const ManagerRoomsScreen(),
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
                    'Manage hotel bookings',
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
                        const ManagerBookingsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Customers
              Card(
                child: ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Customers'),
                  subtitle: const Text(
                    'View customer information',
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
                        const ManagerCustomersScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Service Requests
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.room_service,
                  ),
                  title: const Text('Service Requests'),
                  subtitle: const Text(
                    'Manage hotel service requests',
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
                        const ManagerServiceRequestsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Customer Requests
              Card(
                child: ListTile(
                  leading: const Icon(Icons.message),
                  title: const Text('Customer Requests'),
                  subtitle: const Text(
                    'Handle customer requests',
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
                        const ManagerCustomerRequestsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}