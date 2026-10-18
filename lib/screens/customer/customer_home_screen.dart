import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'customer_profile_screen.dart';
import 'my_bookings_screen.dart';
import 'room_list_screen.dart';
import 'services_screen.dart';
import 'customer_requests_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  final UserModel user;

  const CustomerHomeScreen({
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
        title: const Text('Customer Home'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerProfileScreen(
                    user: user,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Profile',
          ),
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

              // Search Rooms
              Card(
                child: ListTile(
                  leading: const Icon(Icons.hotel),
                  title: const Text('Search Rooms'),
                  subtitle: const Text(
                    'Find available rooms',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoomListScreen(
                          user: user,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // My Bookings
              Card(
                child: ListTile(
                  leading: const Icon(Icons.book_online),
                  title: const Text('My Bookings'),
                  subtitle: const Text(
                    'View your bookings',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyBookingsScreen(
                          user: user,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Hotel Services
              Card(
                child: ListTile(
                  leading: const Icon(Icons.room_service),
                  title: const Text('Hotel Services'),
                  subtitle: const Text(
                    'Request hotel services',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServicesScreen(
                          user: user,
                        ),
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
                  title: const Text('My Requests'),
                  subtitle: const Text(
                    'View your requests',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerRequestsScreen(
                          user: user,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // My Profile
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('My Profile'),
                  subtitle: const Text(
                    'View and update your profile',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerProfileScreen(
                          user: user,
                        ),
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