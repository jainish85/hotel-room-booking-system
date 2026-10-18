import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({
    super.key,
  });

  Future<Map<String, dynamic>> loadReportData() async {
    final firestore = FirebaseFirestore.instance;

    final usersSnapshot =
    await firestore.collection('users').get();

    final roomsSnapshot =
    await firestore.collection('rooms').get();

    final bookingsSnapshot =
    await firestore.collection('bookings').get();

    final servicesSnapshot =
    await firestore.collection('services').get();

    int customers = 0;
    int managers = 0;
    int administrators = 0;

    for (final document in usersSnapshot.docs) {
      final role =
          document.data()['role'] as String? ?? '';

      switch (role) {
        case 'customer':
          customers++;
          break;

        case 'manager':
          managers++;
          break;

        case 'administrator':
          administrators++;
          break;
      }
    }

    int availableRooms = 0;
    int bookedRooms = 0;
    int occupiedRooms = 0;
    int cleaningRooms = 0;
    int maintenanceRooms = 0;

    for (final document in roomsSnapshot.docs) {
      final data = document.data();

      final isActive =
          data['isActive'] as bool? ?? true;

      if (!isActive) {
        continue;
      }

      final status =
          data['status'] as String? ?? 'available';

      switch (status) {
        case 'available':
          availableRooms++;
          break;

        case 'booked':
          bookedRooms++;
          break;

        case 'occupied':
          occupiedRooms++;
          break;

        case 'cleaning':
          cleaningRooms++;
          break;

        case 'maintenance':
          maintenanceRooms++;
          break;
      }
    }

    int pendingBookings = 0;
    int confirmedBookings = 0;
    int checkedInBookings = 0;
    int checkedOutBookings = 0;
    int cancelledBookings = 0;
    int completedBookings = 0;

    double totalRevenue = 0;

    for (final document in bookingsSnapshot.docs) {
      final data = document.data();

      final status =
          data['status'] as String? ?? 'pending';

      final amount =
          (data['totalAmount'] as num?)?.toDouble() ?? 0;

      switch (status) {
        case 'pending':
          pendingBookings++;
          break;

        case 'confirmed':
          confirmedBookings++;
          totalRevenue += amount;
          break;

        case 'checkedIn':
          checkedInBookings++;
          totalRevenue += amount;
          break;

        case 'checkedOut':
          checkedOutBookings++;
          totalRevenue += amount;
          break;

        case 'cancelled':
          cancelledBookings++;
          break;

        case 'completed':
          completedBookings++;
          totalRevenue += amount;
          break;
      }
    }

    int activeServices = 0;

    for (final document in servicesSnapshot.docs) {
      final isActive =
          document.data()['isActive'] as bool? ?? true;

      if (isActive) {
        activeServices++;
      }
    }

    return {
      'totalUsers': usersSnapshot.docs.length,
      'customers': customers,
      'managers': managers,
      'administrators': administrators,

      'totalRooms': roomsSnapshot.docs.length,
      'availableRooms': availableRooms,
      'bookedRooms': bookedRooms,
      'occupiedRooms': occupiedRooms,
      'cleaningRooms': cleaningRooms,
      'maintenanceRooms': maintenanceRooms,

      'totalBookings': bookingsSnapshot.docs.length,
      'pendingBookings': pendingBookings,
      'confirmedBookings': confirmedBookings,
      'checkedInBookings': checkedInBookings,
      'checkedOutBookings': checkedOutBookings,
      'cancelledBookings': cancelledBookings,
      'completedBookings': completedBookings,
      'totalRevenue': totalRevenue,

      'totalServices': servicesSnapshot.docs.length,
      'activeServices': activeServices,
    };
  }

  Widget reportCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load reports.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data;

          if (data == null) {
            return const Center(
              child: Text(
                'No report data available.',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Hotel System Reports',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Current summary of users, rooms, bookings and services.',
              ),

              sectionTitle('Users'),

              reportCard(
                context: context,
                title: 'Total Users',
                value: '${data['totalUsers']}',
                icon: Icons.people_outline,
              ),

              reportCard(
                context: context,
                title: 'Customers',
                value: '${data['customers']}',
                icon: Icons.person_outline,
              ),

              reportCard(
                context: context,
                title: 'Managers',
                value: '${data['managers']}',
                icon: Icons.manage_accounts_outlined,
              ),

              reportCard(
                context: context,
                title: 'Administrators',
                value: '${data['administrators']}',
                icon:
                Icons.admin_panel_settings_outlined,
              ),

              sectionTitle('Rooms'),

              reportCard(
                context: context,
                title: 'Total Rooms',
                value: '${data['totalRooms']}',
                icon: Icons.hotel_outlined,
              ),

              reportCard(
                context: context,
                title: 'Available',
                value: '${data['availableRooms']}',
                icon: Icons.check_circle_outline,
              ),

              reportCard(
                context: context,
                title: 'Booked',
                value: '${data['bookedRooms']}',
                icon: Icons.book_online_outlined,
              ),

              reportCard(
                context: context,
                title: 'Occupied',
                value: '${data['occupiedRooms']}',
                icon: Icons.person,
              ),

              reportCard(
                context: context,
                title: 'Cleaning',
                value: '${data['cleaningRooms']}',
                icon: Icons.cleaning_services_outlined,
              ),

              reportCard(
                context: context,
                title: 'Maintenance',
                value: '${data['maintenanceRooms']}',
                icon: Icons.build_outlined,
              ),

              sectionTitle('Bookings'),

              reportCard(
                context: context,
                title: 'Total Bookings',
                value: '${data['totalBookings']}',
                icon: Icons.book_outlined,
              ),

              reportCard(
                context: context,
                title: 'Pending',
                value: '${data['pendingBookings']}',
                icon: Icons.schedule,
              ),

              reportCard(
                context: context,
                title: 'Confirmed',
                value: '${data['confirmedBookings']}',
                icon: Icons.check_circle_outline,
              ),

              reportCard(
                context: context,
                title: 'Checked-In',
                value: '${data['checkedInBookings']}',
                icon: Icons.login,
              ),

              reportCard(
                context: context,
                title: 'Checked-Out',
                value: '${data['checkedOutBookings']}',
                icon: Icons.logout,
              ),

              reportCard(
                context: context,
                title: 'Cancelled',
                value: '${data['cancelledBookings']}',
                icon: Icons.cancel_outlined,
              ),

              reportCard(
                context: context,
                title: 'Completed',
                value: '${data['completedBookings']}',
                icon: Icons.task_alt,
              ),

              reportCard(
                context: context,
                title: 'Booking Revenue',
                value:
                '₹${(data['totalRevenue'] as double).toStringAsFixed(0)}',
                icon: Icons.currency_rupee,
              ),

              sectionTitle('Services'),

              reportCard(
                context: context,
                title: 'Total Services',
                value: '${data['totalServices']}',
                icon: Icons.room_service_outlined,
              ),

              reportCard(
                context: context,
                title: 'Active Services',
                value: '${data['activeServices']}',
                icon: Icons.check_circle_outline,
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}