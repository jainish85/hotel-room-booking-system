import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../services/booking_service.dart';

class MyBookingsScreen extends StatelessWidget {
  final UserModel user;

  const MyBookingsScreen({
    super.key,
    required this.user,
  });

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String statusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checkedIn:
        return 'Checked-In';
      case BookingStatus.checkedOut:
        return 'Checked-Out';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  Color statusColor(
      BuildContext context,
      BookingStatus status,
      ) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.checkedIn:
        return Colors.blue;
      case BookingStatus.checkedOut:
        return Colors.purple;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.grey;
    }
  }

  Future<void> cancelBooking(
      BuildContext context,
      String bookingId,
      ) async {
    try {
      await BookingService().cancelBooking(
        bookingId,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking cancelled successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to cancel booking.',
          ),
        ),
      );
    }
  }

  void confirmCancellation(
      BuildContext context,
      BookingModel booking,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking?'),
          content: Text(
            'Are you sure you want to cancel '
                'booking ${booking.id}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await cancelBooking(
                  context,
                  booking.id,
                );
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  void showBookingDetails(
      BuildContext context,
      BookingModel booking,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Booking Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text('Booking ID: ${booking.id}'),
                const SizedBox(height: 8),
                Text('Room: ${booking.roomName}'),
                const SizedBox(height: 8),
                Text(
                  'Room Number: ${booking.roomNumber}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Check-in: ${formatDate(booking.checkIn)}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Check-out: ${formatDate(booking.checkOut)}',
                ),
                const SizedBox(height: 8),
                Text('Guests: ${booking.guests}'),
                const SizedBox(height: 8),
                Text(
                  'Nights: ${booking.numberOfNights}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ₹${booking.totalAmount.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${statusText(booking.status)}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: BookingService().watchCustomerBookings(
          user.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load bookings.',
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_online_outlined,
                    size: 70,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your bookings will appear here.',
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              final color = statusColor(
                context,
                booking.status,
              );

              final canCancel =
                  booking.status ==
                      BookingStatus.pending ||
                      booking.status ==
                          BookingStatus.confirmed;

              return Card(
                margin:
                const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.hotel),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              booking.roomName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusText(
                                booking.status,
                              ),
                              style: TextStyle(
                                color: color,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Booking ID: ${booking.id}',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Room ${booking.roomNumber}',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${formatDate(booking.checkIn)} → '
                            '${formatDate(booking.checkOut)}',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${booking.guests} guest(s) • '
                            '${booking.numberOfNights} night(s)',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${booking.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                showBookingDetails(
                                  context,
                                  booking,
                                );
                              },
                              child: const Text(
                                'View Details',
                              ),
                            ),
                          ),
                          if (canCancel) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  confirmCancellation(
                                    context,
                                    booking,
                                  );
                                },
                                child: const Text(
                                  'Cancel',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}