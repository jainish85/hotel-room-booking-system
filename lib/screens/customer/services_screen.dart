import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/service_model.dart';
import '../../models/service_request_model.dart';
import '../../models/user_model.dart';
import '../../services/service_service.dart';
import 'customer_requests_screen.dart';

class ServicesScreen extends StatefulWidget {
  final UserModel user;

  const ServicesScreen({
    super.key,
    required this.user,
  });

  @override
  State<ServicesScreen> createState() =>
      _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ServiceService serviceService =
  ServiceService();

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // DATE HELPERS
  // ============================================================

  DateTime readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  String formatDate(dynamic value) {
    final date = readDate(value);

    return '${date.day}/${date.month}/${date.year}';
  }

  // ============================================================
  // BOOKING STATUS
  // ============================================================

  String bookingStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';

      case 'checkedIn':
        return 'Checked-In';

      default:
        return status;
    }
  }

  // ============================================================
  // GET CUSTOMER BOOKINGS
  // ============================================================

  Future<
      List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getCustomerBookings() async {
    final snapshot = await firestore
        .collection('bookings')
        .where(
      'customerId',
      isEqualTo: widget.user.id,
    )
        .get();

    final bookings = snapshot.docs.where((doc) {
      final data = doc.data();

      final status =
          data['status'] as String? ?? '';

      return status == 'confirmed' ||
          status == 'checkedIn';
    }).toList();

    bookings.sort((a, b) {
      final aDate =
      readDate(a.data()['checkIn']);

      final bDate =
      readDate(b.data()['checkIn']);

      return aDate.compareTo(bDate);
    });

    return bookings;
  }

  // ============================================================
  // SELECT BOOKING
  // ============================================================

  Future<
      QueryDocumentSnapshot<Map<String, dynamic>>?>
  selectBooking() async {
    try {
      final bookings =
      await getCustomerBookings();

      if (!mounted) {
        return null;
      }

      if (bookings.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You need a confirmed or checked-in booking to request a hotel service.',
            ),
          ),
        );

        return null;
      }

      return showModalBottomSheet<
          QueryDocumentSnapshot<Map<String, dynamic>>>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Booking',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Choose the booking for this service request.',
                    ),

                    const SizedBox(height: 18),

                    ...bookings.map(
                          (booking) {
                        final data =
                        booking.data();

                        final roomName =
                            data['roomName']
                            as String? ??
                                '';

                        final roomNumber =
                            data['roomNumber']
                            as String? ??
                                '';

                        final checkIn =
                        data['checkIn'];

                        final checkOut =
                        data['checkOut'];

                        final status =
                            data['status']
                            as String? ??
                                '';

                        return Card(
                          margin:
                          const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: ListTile(
                            leading:
                            const CircleAvatar(
                              child: Icon(
                                Icons.hotel,
                              ),
                            ),
                            title: Text(
                              roomName.isEmpty
                                  ? 'Hotel Room'
                                  : roomName,
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Room ${roomNumber.isEmpty ? '-' : roomNumber}\n'
                                  '${formatDate(checkIn)} → ${formatDate(checkOut)}\n'
                                  '${bookingStatusText(status)}',
                            ),
                            isThreeLine: true,
                            trailing:
                            const Icon(
                              Icons
                                  .arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.pop(
                                sheetContext,
                                booking,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) {
        return null;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load your bookings.\n$e',
          ),
        ),
      );

      return null;
    }
  }

  // ============================================================
  // SELECTED BOOKING CARD
  // ============================================================

  Widget buildSelectedBooking(
      QueryDocumentSnapshot<Map<String, dynamic>>
      booking,
      ) {
    final data = booking.data();

    final roomName =
        data['roomName'] as String? ?? '';

    final roomNumber =
        data['roomNumber'] as String? ?? '';

    final checkIn =
    data['checkIn'];

    final checkOut =
    data['checkOut'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Booking',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Booking ID: ${booking.id}',
          ),

          const SizedBox(height: 4),

          Text(
            'Room: '
                '${roomName.isEmpty ? '-' : roomName}',
          ),

          const SizedBox(height: 4),

          Text(
            'Room Number: '
                '${roomNumber.isEmpty ? '-' : roomNumber}',
          ),

          const SizedBox(height: 4),

          Text(
            'Stay: '
                '${formatDate(checkIn)} → '
                '${formatDate(checkOut)}',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REQUEST SERVICE DIALOG
  // ============================================================

  Future<void> showRequestDialog(
      ServiceModel service,
      ) async {
   // final controller = TextEditingController();
    String requestDetails = '';

    bool isSubmitting = false;

    QueryDocumentSnapshot<
        Map<String, dynamic>>?
    selectedBooking;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              dialogBuilderContext,
              setDialogState,
              )
          {
            return AlertDialog(
              title: Text(
                service.name,
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.description,
                    ),

                    const SizedBox(height: 12),

                    if (service.price > 0)
                      Text(
                        'Price: ₹${service.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      )
                    else
                      const Text(
                        'Price: Free',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                          final booking =
                          await selectBooking();

                          if (booking == null) {
                            return;
                          }

                          if (!dialogContext.mounted) {
                            return;
                          }

                          setDialogState(() {
                            selectedBooking =
                                booking;
                          });
                        },
                        icon: const Icon(
                          Icons.calendar_month,
                        ),
                        label: Text(
                          selectedBooking == null
                              ? 'Select Booking'
                              : 'Change Booking',
                        ),
                      ),
                    ),

                    if (selectedBooking != null) ...[
                      const SizedBox(height: 10),
                      buildSelectedBooking(
                        selectedBooking!,
                      ),
                    ],

                    const SizedBox(height: 20),

                    TextField(
                      maxLines: 4,
                      textCapitalization:
                      TextCapitalization.sentences,
                      onChanged: (value) {
                        requestDetails = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Request Details',
                        hintText: 'Enter what you need...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                    final description =
                    requestDetails.trim();

                    if (selectedBooking == null) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select a booking.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (description.isEmpty) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter request details.',
                          ),
                        ),
                      );

                      return;
                    }

                    setDialogState(() {
                      isSubmitting = true;
                    });

                    try {
                      final request =
                      ServiceRequestModel(
                        id: '',
                        customerId:
                        widget.user.id,
                        customerName:
                        widget.user.name,
                        customerPhone:
                        widget.user.phone,
                        serviceType:
                        service.name,
                        description:
                        description,
                        bookingId:
                        selectedBooking!.id,
                        status:
                        ServiceRequestStatus
                            .pending,
                        createdAt: null,
                      );

                      await firestore
                          .collection(
                        'service_requests',
                      )
                          .add(
                        request.toFirestore(),
                      );

                      if (!mounted) return;

                      if (dialogContext.mounted) {
                        Navigator.pop(
                          dialogContext,
                        );
                      }

                      if (!mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Service request submitted successfully.',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      if (dialogContext.mounted) {
                        setDialogState(() {
                          isSubmitting =
                          false;
                        });
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to submit service request.\n$e',
                          ),
                        ),
                      );
                    }
                  },
                  child: isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Submit Request',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // controller.dispose();
  }



  // ============================================================
  // OPEN MY REQUESTS
  // ============================================================

  void openMyRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerRequestsScreen(
          user: widget.user,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hotel Services',
        ),
        actions: [
          IconButton(
            tooltip: 'My Requests',
            icon: const Icon(
              Icons.receipt_long,
            ),
            onPressed: openMyRequests,
          ),
        ],
      ),

      body: StreamBuilder<List<ServiceModel>>(
        stream:
        serviceService.watchActiveServices(),
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
                  'Unable to load hotel services.\n\n'
                      '${snapshot.error}',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            );
          }

          final services =
              snapshot.data ?? [];

          if (services.isEmpty) {
            return const Center(
              child: Padding(
                padding:
                EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .room_service_outlined,
                      size: 70,
                    ),

                    SizedBox(height: 15),

                    Text(
                      'No services available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Hotel services will appear here when they are added.',
                      textAlign:
                      TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding:
            const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder:
                (_, _) => const SizedBox(
              height: 12,
            ),
            itemBuilder:
                (context, index) {
              final service =
              services[index];

              return Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            child: Icon(
                              Icons
                                  .room_service_outlined,
                            ),
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          Expanded(
                            child: Text(
                              service.name,
                              style:
                              const TextStyle(
                                fontSize: 19,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),

                          Text(
                            service.price > 0
                                ? '₹${service.price.toStringAsFixed(0)}'
                                : 'Free',
                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight
                                  .bold,
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        service.description,
                        style:
                        const TextStyle(
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      SizedBox(
                        width:
                        double.infinity,
                        child:
                        ElevatedButton.icon(
                          onPressed: () {
                            showRequestDialog(
                              service,
                            );
                          },
                          icon: const Icon(
                            Icons.send,
                          ),
                          label: const Text(
                            'Request Service',
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
    );
  }
}