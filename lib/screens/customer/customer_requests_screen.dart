import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/customer_request_model.dart';
import '../../models/service_request_model.dart';
import '../../models/user_model.dart';
import '../../services/customer_request_service.dart';

class CustomerRequestsScreen extends StatefulWidget {
  final UserModel user;

  const CustomerRequestsScreen({
    super.key,
    required this.user,
  });

  @override
  State<CustomerRequestsScreen> createState() =>
      _CustomerRequestsScreenState();
}

class _CustomerRequestsScreenState
    extends State<CustomerRequestsScreen> {
  final CustomerRequestService customerRequestService =
  CustomerRequestService();

  final TextEditingController subjectController =
  TextEditingController();

  final TextEditingController messageController =
  TextEditingController();

  bool isSubmitting = false;

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  String customerStatusText(
      CustomerRequestStatus status,
      ) {
    switch (status) {
      case CustomerRequestStatus.pending:
        return 'Pending';

      case CustomerRequestStatus.inProgress:
        return 'In Progress';

      case CustomerRequestStatus.resolved:
        return 'Resolved';

      case CustomerRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color customerStatusColor(
      CustomerRequestStatus status,
      ) {
    switch (status) {
      case CustomerRequestStatus.pending:
        return Colors.orange;

      case CustomerRequestStatus.inProgress:
        return Colors.blue;

      case CustomerRequestStatus.resolved:
        return Colors.green;

      case CustomerRequestStatus.cancelled:
        return Colors.red;
    }
  }

  IconData customerStatusIcon(
      CustomerRequestStatus status,
      ) {
    switch (status) {
      case CustomerRequestStatus.pending:
        return Icons.schedule;

      case CustomerRequestStatus.inProgress:
        return Icons.autorenew;

      case CustomerRequestStatus.resolved:
        return Icons.task_alt;

      case CustomerRequestStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String serviceStatusText(
      ServiceRequestStatus status,
      ) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 'Pending';

      case ServiceRequestStatus.accepted:
        return 'Accepted';

      case ServiceRequestStatus.inProgress:
        return 'In Progress';

      case ServiceRequestStatus.completed:
        return 'Completed';

      case ServiceRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color serviceStatusColor(
      ServiceRequestStatus status,
      ) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Colors.orange;

      case ServiceRequestStatus.accepted:
        return Colors.green;

      case ServiceRequestStatus.inProgress:
        return Colors.blue;

      case ServiceRequestStatus.completed:
        return Colors.purple;

      case ServiceRequestStatus.cancelled:
        return Colors.red;
    }
  }

  IconData serviceStatusIcon(
      ServiceRequestStatus status,
      ) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Icons.schedule;

      case ServiceRequestStatus.accepted:
        return Icons.check_circle_outline;

      case ServiceRequestStatus.inProgress:
        return Icons.autorenew;

      case ServiceRequestStatus.completed:
        return Icons.task_alt;

      case ServiceRequestStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Date unavailable';
    }

    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> submitCustomerRequest() async {
    final subject =
    subjectController.text.trim();

    final message =
    messageController.text.trim();

    if (subject.isEmpty) {
      showMessage(
        'Please enter a subject.',
      );
      return;
    }

    if (message.isEmpty) {
      showMessage(
        'Please enter your request.',
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await customerRequestService.createRequest(
        customerId: widget.user.id,
        customerName: widget.user.name,
        customerPhone: widget.user.phone,
        subject: subject,
        message: message,
      );

      if (!mounted) return;

      subjectController.clear();
      messageController.clear();

      setState(() {
        isSubmitting = false;
      });

      FocusScope.of(context).unfocus();

      showMessage(
        'Request submitted successfully.',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      showMessage(
        'Unable to submit request.',
      );
    }
  }

  Future<void> cancelCustomerRequest(
      CustomerRequestModel request,
      ) async {
    final shouldCancel =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cancel Request',
          ),
          content: const Text(
            'Are you sure you want to cancel this request?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Yes, Cancel',
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) {
      return;
    }

    try {
      await customerRequestService.cancelRequest(
        request.id,
      );

      if (!mounted) return;

      showMessage(
        'Request cancelled successfully.',
      );
    } catch (_) {
      if (!mounted) return;

      showMessage(
        'Unable to cancel request.',
      );
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget buildCustomerRequestCard(
      CustomerRequestModel request,
      ) {
    final color =
    customerStatusColor(request.status);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.subject,
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
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Icon(
                        customerStatusIcon(
                          request.status,
                        ),
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        customerStatusText(
                          request.status,
                        ),
                        style: TextStyle(
                          color: color,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(request.message),
            const SizedBox(height: 10),
            Text(
              formatDate(
                request.createdAt,
              ),
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
            if (request.status ==
                CustomerRequestStatus.pending)
              ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child:
                  OutlinedButton.icon(
                    onPressed: () {
                      cancelCustomerRequest(
                        request,
                      );
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                    ),
                    label: const Text(
                      'Cancel Request',
                    ),
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }

  Widget buildServiceRequestCard(
      ServiceRequestModel request,
      ) {
    final color =
    serviceStatusColor(request.status);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.room_service,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    request.serviceType,
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
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Icon(
                        serviceStatusIcon(
                          request.status,
                        ),
                        size: 16,
                        color: color,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        serviceStatusText(
                          request.status,
                        ),
                        style: TextStyle(
                          color: color,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Request ID: ${request.id}',
            ),

            const SizedBox(height: 6),

            Text(
              'Booking ID: '
                  '${request.bookingId ?? 'Not linked'}',
            ),

            const SizedBox(height: 8),

            Text(
              request.description,
            ),

            const SizedBox(height: 8),

            Text(
              'Requested: '
                  '${formatDate(request.createdAt)}',
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGeneralRequestsTab() {
    return StreamBuilder<
        List<CustomerRequestModel>>(
      stream: customerRequestService
          .watchCustomerRequests(
        widget.user.id,
      ),
      builder: (
          context,
          snapshot,
          ) {
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
                'Unable to load requests.\n\n'
                    '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final requests =
            snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Create a Request',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Contact the hotel about any issue, question, or special requirement.',
              ),

              const SizedBox(height: 20),

              TextField(
                controller:
                subjectController,
                decoration:
                const InputDecoration(
                  labelText: 'Subject',
                  hintText:
                  'Enter request subject',
                  prefixIcon:
                  Icon(Icons.title),
                  border:
                  OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller:
                messageController,
                maxLines: 5,
                decoration:
                const InputDecoration(
                  labelText: 'Request',
                  hintText:
                  'Describe your request',
                  alignLabelWithHint: true,
                  prefixIcon:
                  Icon(
                    Icons.message_outlined,
                  ),
                  border:
                  OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                  isSubmitting
                      ? null
                      : submitCustomerRequest,
                  icon: isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.send,
                  ),
                  label: Text(
                    isSubmitting
                        ? 'Submitting...'
                        : 'Submit Request',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Previous Requests',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              if (requests.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No general requests yet.',
                      ),
                    ),
                  ),
                )
              else
                ...requests.map(
                  buildCustomerRequestCard,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildServiceRequestsTab() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('service_requests')
          .where(
        'customerId',
        isEqualTo: widget.user.id,
      )
          .snapshots(),
      builder: (
          context,
          snapshot,
          ) {
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
                'Unable to load service requests.\n\n'
                    '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final requests =
            snapshot.data?.docs
                .map(
                  (doc) =>
                  ServiceRequestModel
                      .fromFirestore(
                    doc.id,
                    doc.data(),
                  ),
            )
                .toList() ??
                [];

        requests.sort(
              (a, b) {
            final aDate =
                a.createdAt ??
                    DateTime(2000);

            final bDate =
                b.createdAt ??
                    DateTime(2000);

            return bDate.compareTo(aDate);
          },
        );

        if (requests.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No hotel service requests yet.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder:
              (_, _) =>
          const SizedBox(height: 12),
          itemBuilder: (
              context,
              index,
              ) {
            return buildServiceRequestCard(
              requests[index],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Requests',
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.room_service,
                ),
                text: 'Services',
              ),
              Tab(
                icon: Icon(
                  Icons.message_outlined,
                ),
                text: 'General Requests',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildServiceRequestsTab(),
            buildGeneralRequestsTab(),
          ],
        ),
      ),
    );
  }
}