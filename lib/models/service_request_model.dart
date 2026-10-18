import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceRequestStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}

class ServiceRequestModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String serviceType;
  final String description;
  final String? bookingId;
  final ServiceRequestStatus status;
  final DateTime? createdAt;

  const ServiceRequestModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceType,
    required this.description,
    required this.bookingId,
    required this.status,
    required this.createdAt,
  });

  factory ServiceRequestModel.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return ServiceRequestModel(
      id: id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      serviceType: data['serviceType'] as String? ?? '',
      description: data['description'] as String? ?? '',
      bookingId: data['bookingId'] as String?,
      status: _statusFromString(
        data['status'] as String? ?? 'pending',
      ),
      createdAt: data['createdAt'] == null
          ? null
          : _toDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceType': serviceType,
      'description': description,
      'bookingId': bookingId,
      'status': status.name,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  static ServiceRequestStatus _statusFromString(
      String status,
      ) {
    switch (status) {
      case 'accepted':
        return ServiceRequestStatus.accepted;

      case 'inProgress':
        return ServiceRequestStatus.inProgress;

      case 'completed':
        return ServiceRequestStatus.completed;

      case 'cancelled':
        return ServiceRequestStatus.cancelled;

      default:
        return ServiceRequestStatus.pending;
    }
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}