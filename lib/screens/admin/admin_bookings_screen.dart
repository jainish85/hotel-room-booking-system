import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({
    super.key,
  });

  @override
  State<AdminBookingsScreen> createState() =>
      _AdminBookingsScreenState();
}

class _AdminBookingsScreenState
    extends State<AdminBookingsScreen> {
  final BookingService bookingService =
  BookingService();

  final TextEditingController searchController =
  TextEditingController();

  String searchText = '';

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {
        searchText =
            searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

  String formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> updateStatus(
      BookingModel booking,
      ) async {
    BookingStatus selectedStatus =
        booking.status;

    final newStatus =
    await showDialog<BookingStatus>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Update Booking Status',
          ),
          content: StatefulBuilder(
            builder: (
                context,
                setState,
                ) {
              return DropdownButtonFormField<BookingStatus>(
                initialValue: selectedStatus,
                decoration:
                const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: BookingStatus.values.map(
                      (status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        statusText(status),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedStatus = value;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  selectedStatus,
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (newStatus == null ||
        newStatus == booking.status) {
      return;
    }

    try {
      await bookingService.updateBookingStatus(
        bookingId: booking.id,
        status: newStatus,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking status updated successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update booking status.',
          ),
        ),
      );
    }
  }

  void showBookingDetails(
      BookingModel booking,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        final color =
        statusColor(booking.status);

        return AlertDialog(
          title: const Text(
            'Booking Details',
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking ID: ${booking.id}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Customer: ${booking.customerName}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Phone: ${booking.customerPhone}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Room: ${booking.roomName}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Room Number: ${booking.roomNumber}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Check-in: ${formatDate(booking.checkIn)}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Check-out: ${formatDate(booking.checkOut)}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Guests: ${booking.guests}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Nights: ${booking.numberOfNights}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Room Price: ₹${booking.roomPrice.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Total Amount: ₹${booking.totalAmount.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusText(
                        booking.status,
                      ),
                      style: TextStyle(
                        color: color,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
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
        title: const Text(
          'Booking Management',
        ),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: bookingService.watchAllBookings(),
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Text(
                  'Unable to load bookings.\n\n${snapshot.error}',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            );
          }

          final allBookings =
              snapshot.data ?? [];

          final bookings =
          allBookings.where((booking) {
            if (searchText.isEmpty) {
              return true;
            }

            return booking.id
                .toLowerCase()
                .contains(searchText) ||
                booking.customerName
                    .toLowerCase()
                    .contains(searchText) ||
                booking.customerPhone
                    .toLowerCase()
                    .contains(searchText) ||
                booking.roomName
                    .toLowerCase()
                    .contains(searchText) ||
                booking.roomNumber
                    .toLowerCase()
                    .contains(searchText);
          }).toList();

          return Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.all(16),
                child: TextField(
                  controller:
                  searchController,
                  decoration:
                  const InputDecoration(
                    prefixIcon:
                    Icon(Icons.search),
                    labelText:
                    'Search bookings',
                    hintText:
                    'Booking ID, customer, phone or room',
                    border:
                    OutlineInputBorder(),
                  ),
                ),
              ),

              Expanded(
                child: bookings.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons
                            .book_online_outlined,
                        size: 70,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'No bookings found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16,
                  ),
                  itemCount:
                  bookings.length,
                  separatorBuilder:
                      (_, _) =>
                  const SizedBox(
                    height: 12,
                  ),
                  itemBuilder:
                      (context, index) {
                    final booking =
                    bookings[index];

                    final color =
                    statusColor(
                      booking.status,
                    );

                    return Card(
                      child: Padding(
                        padding:
                        const EdgeInsets
                            .all(16),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.hotel,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    booking
                                        .roomName,
                                    style:
                                    const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color: color
                                        .withValues(
                                      alpha:
                                      0.12,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      20,
                                    ),
                                  ),
                                  child:
                                  Text(
                                    statusText(
                                      booking
                                          .status,
                                    ),
                                    style:
                                    TextStyle(
                                      color:
                                      color,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 12),

                            Text(
                              'Booking ID: ${booking.id}',
                            ),

                            const SizedBox(
                                height: 6),

                            Text(
                              'Customer: ${booking.customerName}',
                            ),

                            const SizedBox(
                                height: 6),

                            Text(
                              'Phone: ${booking.customerPhone}',
                            ),

                            const SizedBox(
                                height: 6),

                            Text(
                              'Room ${booking.roomNumber}',
                            ),

                            const SizedBox(
                                height: 6),

                            Text(
                              '${formatDate(booking.checkIn)} → '
                                  '${formatDate(booking.checkOut)}',
                            ),

                            const SizedBox(
                                height: 6),

                            Text(
                              '${booking.guests} guest(s) • '
                                  '${booking.numberOfNights} night(s)',
                            ),

                            const SizedBox(
                                height: 6),

                            Text(
                              '₹${booking.totalAmount.toStringAsFixed(0)}',
                              style:
                              const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            const SizedBox(
                                height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child:
                                  OutlinedButton(
                                    onPressed:
                                        () {
                                      showBookingDetails(
                                        booking,
                                      );
                                    },
                                    child:
                                    const Text(
                                      'View Details',
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    width: 10),
                                Expanded(
                                  child:
                                  ElevatedButton(
                                    onPressed:
                                        () {
                                      updateStatus(
                                        booking,
                                      );
                                    },
                                    child:
                                    const Text(
                                      'Update Status',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}