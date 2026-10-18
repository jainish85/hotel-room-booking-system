import 'package:cloud_firestore/cloud_firestore.dart';

enum CustomerRequestStatus {
  pending,
  inProgress,
  resolved,
  cancelled,
}

class CustomerRequestModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String subject;
  final String message;
  final CustomerRequestStatus status;
  final DateTime? createdAt;

  const CustomerRequestModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory CustomerRequestModel.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return CustomerRequestModel(
      id: id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      message: data['message'] as String? ?? '',
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
      'subject': subject,
      'message': message,
      'status': status.name,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  static CustomerRequestStatus _statusFromString(
      String status,
      ) {
    switch (status) {
      case 'inProgress':
        return CustomerRequestStatus.inProgress;
      case 'resolved':
        return CustomerRequestStatus.resolved;
      case 'cancelled':
        return CustomerRequestStatus.cancelled;
      default:
        return CustomerRequestStatus.pending;
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