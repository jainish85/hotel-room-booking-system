import 'package:flutter/material.dart';

import '../../models/service_request_model.dart';
import '../../services/service_request_service.dart';

class ManagerServiceRequestsScreen extends StatelessWidget {
  const ManagerServiceRequestsScreen({super.key});

  ServiceRequestService get requestService =>
      ServiceRequestService();

  String statusText(ServiceRequestStatus status) {
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

  Color statusColor(
      BuildContext context,
      ServiceRequestStatus status,
      ) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Colors.orange;
      case ServiceRequestStatus.accepted:
        return Colors.blue;
      case ServiceRequestStatus.inProgress:
        return Colors.indigo;
      case ServiceRequestStatus.completed:
        return Colors.green;
      case ServiceRequestStatus.cancelled:
        return Colors.red;
    }
  }

  IconData statusIcon(ServiceRequestStatus status) {
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

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  Future<void> updateStatus(
      BuildContext context,
      ServiceRequestModel request,
      ) async {
    ServiceRequestStatus selectedStatus = request.status;

    final newStatus = await showDialog<ServiceRequestStatus>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Request Status'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<ServiceRequestStatus>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ServiceRequestStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(statusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedStatus = value;
                  });
                },
              );
            },
          ),
        );
      },
    );

    if (newStatus == null || newStatus == request.status) {
      return;
    }

    try {
      await requestService.updateRequestStatus(
        requestId: request.id,
        status: newStatus,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Request status updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update request status.',
          ),
        ),
      );
    }
  }

  void showRequestDetails(
      BuildContext context,
      ServiceRequestModel request,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        final color = statusColor(
          context,
          request.status,
        );

        return AlertDialog(
          title: const Text('Service Request Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request ID: ${request.id}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Customer: ${request.customerName}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Phone: ${request.customerPhone}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Service: ${request.serviceType}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Description: ${request.description}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Created: ${formatDate(request.createdAt)}',
                ),
                if (request.bookingId != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Booking ID: ${request.bookingId}',
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      statusIcon(request.status),
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusText(request.status),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
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
        title: const Text('Service Requests'),
      ),
      body: StreamBuilder<List<ServiceRequestModel>>(
        stream: requestService.watchAllRequests(),
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
                  'Unable to load service requests.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.room_service_outlined,
                      size: 70,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No service requests',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Customer service requests will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, _) =>
            const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = requests[index];

              final color = statusColor(
                context,
                request.status,
              );

              return Card(
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
                              request.serviceType,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusIcon(
                                    request.status,
                                  ),
                                  size: 16,
                                  color: color,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  statusText(
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

                      const SizedBox(height: 12),

                      Text(
                        'Customer: ${request.customerName}',
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Phone: ${request.customerPhone}',
                      ),

                      const SizedBox(height: 6),

                      Text(
                        request.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Created: ${formatDate(request.createdAt)}',
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                showRequestDetails(
                                  context,
                                  request,
                                );
                              },
                              child: const Text(
                                'View Details',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                updateStatus(
                                  context,
                                  request,
                                );
                              },
                              child: const Text(
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
          );
        },
      ),
    );
  }
}