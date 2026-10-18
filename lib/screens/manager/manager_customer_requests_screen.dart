import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/customer_request_model.dart';
import '../../models/service_request_model.dart';
import '../../services/customer_request_service.dart';

class ManagerCustomerRequestsScreen
    extends StatefulWidget {
  const ManagerCustomerRequestsScreen({
    super.key,
  });

  @override
  State<ManagerCustomerRequestsScreen>
  createState() =>
      _ManagerCustomerRequestsScreenState();
}

class _ManagerCustomerRequestsScreenState
    extends State<ManagerCustomerRequestsScreen> {
  final CustomerRequestService customerRequestService =
  CustomerRequestService();

  final TextEditingController searchController =
  TextEditingController();

  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
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

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Date unavailable';
    }

    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> updateCustomerRequestStatus(
      CustomerRequestModel request,
      ) async {
    CustomerRequestStatus selectedStatus =
        request.status;

    final result =
    await showDialog<CustomerRequestStatus>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Update Customer Request',
          ),
          content: StatefulBuilder(
            builder: (
                dialogContext,
                setDialogState,
                ) {
              return DropdownButtonFormField<
                  CustomerRequestStatus>(
                initialValue: selectedStatus,
                decoration:
                const InputDecoration(
                  labelText: 'Status',
                  border:
                  OutlineInputBorder(),
                ),
                items:
                CustomerRequestStatus.values
                    .map(
                      (status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        customerStatusText(
                          status,
                        ),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setDialogState(() {
                    selectedStatus =
                        value;
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

    if (result == null ||
        result == request.status) {
      return;
    }

    try {
      await customerRequestService
          .updateRequestStatus(
        requestId: request.id,
        status: result,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Customer request updated.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update customer request.',
          ),
        ),
      );
    }
  }

  Future<void> updateServiceRequestStatus(
      ServiceRequestModel request,
      ) async {
    ServiceRequestStatus selectedStatus =
        request.status;

    final result =
    await showDialog<ServiceRequestStatus>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Update Service Request',
          ),
          content: StatefulBuilder(
            builder: (
                dialogContext,
                setDialogState,
                ) {
              return DropdownButtonFormField<
                  ServiceRequestStatus>(
                initialValue: selectedStatus,
                decoration:
                const InputDecoration(
                  labelText: 'Status',
                  border:
                  OutlineInputBorder(),
                ),
                items:
                ServiceRequestStatus.values
                    .map(
                      (status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        serviceStatusText(
                          status,
                        ),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setDialogState(() {
                    selectedStatus =
                        value;
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

    if (result == null ||
        result == request.status) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('service_requests')
          .doc(request.id)
          .update({
        'status': result.name,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Service request updated.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update service request.',
          ),
        ),
      );
    }
  }

  bool matchesCustomerRequest(
      CustomerRequestModel request,
      ) {
    final query =
    searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    return request.id
        .toLowerCase()
        .contains(query) ||
        request.customerName
            .toLowerCase()
            .contains(query) ||
        request.customerPhone
            .toLowerCase()
            .contains(query) ||
        request.subject
            .toLowerCase()
            .contains(query) ||
        request.message
            .toLowerCase()
            .contains(query);
  }

  bool matchesServiceRequest(
      ServiceRequestModel request,
      ) {
    final query =
    searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    return request.id
        .toLowerCase()
        .contains(query) ||
        request.customerName
            .toLowerCase()
            .contains(query) ||
        request.customerPhone
            .toLowerCase()
            .contains(query) ||
        request.serviceType
            .toLowerCase()
            .contains(query) ||
        (request.bookingId ?? '')
            .toLowerCase()
            .contains(query);
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  customerStatusText(
                    request.status,
                  ),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              'Customer: ${request.customerName}',
            ),

            const SizedBox(height: 6),

            Text(
              'Phone: ${request.customerPhone}',
            ),

            const SizedBox(height: 6),

            Text(
              request.message,
            ),

            const SizedBox(height: 8),

            Text(
              formatDate(request.createdAt),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  updateCustomerRequestStatus(
                    request,
                  );
                },
                icon: const Icon(
                  Icons.edit,
                ),
                label: const Text(
                  'Update Status',
                ),
              ),
            ),
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

            const SizedBox(height: 10),

            Text(
              'Customer: '
                  '${request.customerName}',
            ),

            const SizedBox(height: 6),

            Text(
              'Phone: '
                  '${request.customerPhone}',
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
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  updateServiceRequestStatus(
                    request,
                  );
                },
                icon: const Icon(
                  Icons.edit,
                ),
                label: const Text(
                  'Update Status',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomerRequestsTab() {
    return StreamBuilder<
        List<CustomerRequestModel>>(
      stream:
      customerRequestService
          .watchAllRequests(),
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
                'Unable to load customer requests.\n\n'
                    '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final requests =
        (snapshot.data ?? [])
            .where(
          matchesCustomerRequest,
        )
            .toList();

        if (requests.isEmpty) {
          return const Center(
            child: Text(
              'No customer requests found.',
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (
              context,
              index,
              ) {
            return buildCustomerRequestCard(
              requests[index],
            );
          },
        );
      },
    );
  }

  Widget buildServiceRequestsTab() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('service_requests')
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
                .where(
              matchesServiceRequest,
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
            child: Text(
              'No service requests found.',
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
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
            'Request Management',
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.room_service,
                ),
                text: 'Service Requests',
              ),
              Tab(
                icon: Icon(
                  Icons.message_outlined,
                ),
                text: 'Customer Requests',
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller:
                searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration:
                InputDecoration(
                  hintText:
                  'Search customer, phone, service or booking...',
                  prefixIcon:
                  const Icon(
                    Icons.search,
                  ),
                  suffixIcon:
                  searchQuery.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      searchController
                          .clear();

                      setState(() {
                        searchQuery =
                        '';
                      });
                    },
                    icon:
                    const Icon(
                      Icons.clear,
                    ),
                  )
                      : null,
                  border:
                  const OutlineInputBorder(),
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  buildServiceRequestsTab(),
                  buildCustomerRequestsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}