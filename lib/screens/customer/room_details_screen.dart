import 'package:flutter/material.dart';

import '../../models/room_model.dart';
import '../../models/user_model.dart';
import 'booking_screen.dart';

class RoomDetailsScreen extends StatelessWidget {
  final RoomModel room;
  final UserModel user;

  const RoomDetailsScreen({
    super.key,
    required this.room,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isRoomAvailable = room.status == RoomStatus.available;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room image
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
              child: room.imageUrl.trim().isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  room.imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return const Center(
                      child: Icon(
                        Icons.hotel,
                        size: 80,
                      ),
                    );
                  },
                ),
              )
                  : const Center(
                child: Icon(
                  Icons.hotel,
                  size: 80,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Room name
            Text(
              room.roomName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Room type and number
            Text(
              '${room.roomType} • Room ${room.roomNumber}',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 12),

            // Room price
            Text(
              '₹${room.price.toStringAsFixed(0)} / night',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            // Capacity
            Row(
              children: [
                const Icon(Icons.people_outline),
                const SizedBox(width: 8),
                Text(
                  'Capacity: ${room.capacity} guest(s)',
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Room status
            Row(
              children: [
                Icon(
                  isRoomAvailable
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  color: isRoomAvailable
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  isRoomAvailable
                      ? 'Available'
                      : 'Currently unavailable',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isRoomAvailable
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              room.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            // Facilities
            const Text(
              'Facilities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (room.facilities.isEmpty)
              const Text(
                'No facilities listed.',
                style: TextStyle(
                  fontSize: 16,
                ),
              )
            else
              ...room.facilities.map(
                    (facility) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.check_circle_outline,
                  ),
                  title: Text(facility),
                ),
              ),

            const SizedBox(height: 20),

            // Book room button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isRoomAvailable
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(
                        room: room,
                        user: user,
                      ),
                    ),
                  );
                }
                    : null,
                icon: const Icon(Icons.book_online),
                label: const Text(
                  'Book This Room',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}