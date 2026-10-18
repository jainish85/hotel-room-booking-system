import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class ManagerBookingsScreen extends StatefulWidget {
  const ManagerBookingsScreen({super.key});

  @override
  State<ManagerBookingsScreen> createState() =>
      _ManagerBookingsScreenState();
}

class _ManagerBookingsScreenState
    extends State<ManagerBookingsScreen> {
  final BookingService bookingService = BookingService();

  final TextEditingController searchController =
  TextEditingController();

  String searchQuery = '';
  String selectedStatusFilter = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<BookingModel> filterBookings(
      List<BookingModel> bookings,
      ) {
    final query = searchQuery.toLowerCase();

    return bookings.where((booking) {
      final matchesSearch =
          query.isEmpty ||
              booking.id.toLowerCase().contains(query) ||
              booking.customerName.toLowerCase().contains(query) ||
              booking.customerPhone.contains(query) ||
              booking.roomNumber.toLowerCase().contains(query) ||
              booking.roomName.toLowerCase().contains(query);

      final matchesStatus =
          selectedStatusFilter == 'All' ||
              statusText(booking.status) == selectedStatusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
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

  Color statusColor(BookingStatus status) {
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
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> updateStatus(
      BookingModel booking,
      BookingStatus status,
      ) async {
    try {
      await bookingService.updateBookingStatus(
        bookingId: booking.id,
        status: status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking ${booking.id} updated to '
                '${statusText(status)}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update booking status: $e',
          ),
        ),
      );
    }
  }

  Future<void> showStatusOptions(
      BookingModel booking,
      ) async {
    final selectedStatus =
    await showDialog<BookingStatus>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text(
            'Update Booking Status',
          ),
          children: BookingStatus.values.map(
                (status) {
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    status,
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: statusColor(status),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      statusText(status),
                    ),
                  ],
                ),
              );
            },
          ).toList(),
        );
      },
    );

    if (selectedStatus == null) {
      return;
    }

    await updateStatus(
      booking,
      selectedStatus,
    );
  }

  Future<void> showFilterDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text(
            'Filter Bookings',
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  'All',
                );
              },
              child: const Text('All Bookings'),
            ),
            ...BookingStatus.values.map(
                  (status) {
                return SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      statusText(status),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: statusColor(status),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        statusText(status),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedStatusFilter = result;
    });
  }

  void showBookingDetails(
      BookingModel booking,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final color = statusColor(booking.status);

        return AlertDialog(
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  'Booking Details',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
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
                  statusText(booking.status),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _detailRow(
                  'Booking ID',
                  booking.id,
                ),
                _detailRow(
                  'Customer',
                  booking.customerName,
                ),
                _detailRow(
                  'Phone',
                  booking.customerPhone,
                ),
                _detailRow(
                  'Room',
                  booking.roomName,
                ),
                _detailRow(
                  'Room Number',
                  booking.roomNumber,
                ),
                _detailRow(
                  'Check-in',
                  formatDate(booking.checkIn),
                ),
                _detailRow(
                  'Check-out',
                  formatDate(booking.checkOut),
                ),
                _detailRow(
                  'Adults',
                  booking.adults.toString(),
                ),
                _detailRow(
                  'Children',
                  booking.children.toString(),
                ),
                if (booking.children > 0 &&
                    booking.childAges.isNotEmpty)
                  _detailRow(
                    'Child Ages',
                    booking.childAges.join(', '),
                  ),
                _detailRow(
                  'Total Guests',
                  booking.guests.toString(),
                ),
                _detailRow(
                  'Nights',
                  booking.numberOfNights.toString(),
                ),
                _detailRow(
                  'Room Price',
                  '₹${booking.roomPrice.toStringAsFixed(0)}',
                ),
                _detailRow(
                  'Total Amount',
                  '₹${booking.totalAmount.toStringAsFixed(0)}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await showStatusOptions(
                  booking,
                );
              },
              icon: const Icon(
                Icons.edit,
              ),
              label: const Text(
                'Update Status',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusFilterChip() {
    if (selectedStatusFilter == 'All') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        12,
      ),
      child: Row(
        children: [
          const Text(
            'Filter:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text(
              selectedStatusFilter,
            ),
            deleteIcon: const Icon(
              Icons.close,
              size: 18,
            ),
            onDeleted: () {
              setState(() {
                selectedStatusFilter = 'All';
              });
            },
          ),
        ],
      ),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText:
                      'Search booking, customer or room...',
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                      suffixIcon:
                      searchQuery.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          searchController.clear();

                          setState(() {
                            searchQuery = '';
                          });
                        },
                        icon: const Icon(
                          Icons.clear,
                        ),
                      )
                          : null,
                      border:
                      const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: showFilterDialog,
                  icon: const Icon(
                    Icons.filter_list,
                  ),
                  label: const Text(
                    'Filter',
                  ),
                ),
              ],
            ),
          ),

          buildStatusFilterChip(),

          Expanded(
            child: StreamBuilder<List<BookingModel>>(
              stream:
              bookingService.watchAllBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load bookings.',
                    ),
                  );
                }

                final allBookings =
                    snapshot.data ?? [];

                final bookings =
                filterBookings(allBookings);

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
                          'No bookings found.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    20,
                  ),
                  itemCount: bookings.length,
                  itemBuilder:
                      (context, index) {
                    final booking =
                    bookings[index];

                    final color =
                    statusColor(
                      booking.status,
                    );

                    return Card(
                      margin:
                      const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: Padding(
                        padding:
                        const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.book_online,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    booking.roomName,
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
                                      alpha: 0.12,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      20,
                                    ),
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

                            const SizedBox(
                              height: 12,
                            ),

                            Text(
                              'Booking ID: ${booking.id}',
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              'Customer: '
                                  '${booking.customerName}',
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              'Room ${booking.roomNumber}',
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              '${formatDate(booking.checkIn)}'
                                  ' → '
                                  '${formatDate(booking.checkOut)}',
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              '${booking.guests} guest(s) • '
                                  '${booking.numberOfNights} night(s)',
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              '₹${booking.totalAmount.toStringAsFixed(0)}',
                              style:
                              const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showBookingDetails(
                                    booking,
                                  );
                                },
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                ),
                                label: const Text(
                                  'View Booking Details',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}