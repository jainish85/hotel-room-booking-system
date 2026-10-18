import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  checkedIn,
  checkedOut,
  cancelled,
  completed,
}

class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String roomId;
  final String roomNumber;
  final String roomName;
  final DateTime checkIn;
  final DateTime checkOut;

  // Guest information
  final int guests;
  final int adults;
  final int children;
  final List<int> childAges;

  final double roomPrice;
  final double totalAmount;
  final BookingStatus status;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.roomId,
    required this.roomNumber,
    required this.roomName,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    this.adults = 1,
    this.children = 0,
    this.childAges = const [],
    required this.roomPrice,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  int get numberOfNights {
    return checkOut.difference(checkIn).inDays;
  }

  factory BookingModel.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    final children = (data['children'] as num?)?.toInt() ?? 0;
    final rawChildAges = data['childAges'];

    final childAges = rawChildAges is List
        ? rawChildAges
        .whereType<num>()
        .map((age) => age.toInt())
        .toList()
        : <int>[];

    return BookingModel(
      id: id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      roomId: data['roomId'] as String? ?? '',
      roomNumber: data['roomNumber'] as String? ?? '',
      roomName: data['roomName'] as String? ?? '',
      checkIn: _toDateTime(data['checkIn']),
      checkOut: _toDateTime(data['checkOut']),
      guests: (data['guests'] as num?)?.toInt() ?? 1,
      adults: (data['adults'] as num?)?.toInt() ??
          ((data['guests'] as num?)?.toInt() ?? 1),
      children: children,
      childAges: childAges,
      roomPrice: (data['roomPrice'] as num?)?.toDouble() ?? 0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
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
      'roomId': roomId,
      'roomNumber': roomNumber,
      'roomName': roomName,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'guests': guests,
      'adults': adults,
      'children': children,
      'childAges': childAges,
      'roomPrice': roomPrice,
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
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

  static BookingStatus _statusFromString(String status) {
    switch (status) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'checkedIn':
        return BookingStatus.checkedIn;
      case 'checkedOut':
        return BookingStatus.checkedOut;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }
}