import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer_request_model.dart';

class CustomerRequestService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
  get _requests =>
      _firestore.collection('customer_requests');

  // ALL CUSTOMER REQUESTS
  Stream<List<CustomerRequestModel>>
  watchAllRequests() {
    return _requests.snapshots().map(
          (snapshot) {
        final requests = snapshot.docs
            .map(
              (doc) => CustomerRequestModel.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
            .toList();

        requests.sort(
              (a, b) {
            final aDate =
                a.createdAt ?? DateTime(2000);

            final bDate =
                b.createdAt ?? DateTime(2000);

            return bDate.compareTo(aDate);
          },
        );

        return requests;
      },
    );
  }

  // CUSTOMER REQUESTS
  Stream<List<CustomerRequestModel>>
  watchCustomerRequests(
      String customerId,
      ) {
    return _requests
        .where(
      'customerId',
      isEqualTo: customerId,
    )
        .snapshots()
        .map(
          (snapshot) {
        final requests = snapshot.docs
            .map(
              (doc) =>
              CustomerRequestModel.fromFirestore(
                doc.id,
                doc.data(),
              ),
        )
            .toList();

        requests.sort(
              (a, b) {
            final aDate =
                a.createdAt ?? DateTime(2000);

            final bDate =
                b.createdAt ?? DateTime(2000);

            return bDate.compareTo(aDate);
          },
        );

        return requests;
      },
    );
  }

  // CREATE CUSTOMER REQUEST
  Future<CustomerRequestModel> createRequest({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String subject,
    required String message,
  }) async {
    final document = _requests.doc();

    final request = CustomerRequestModel(
      id: document.id,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      subject: subject,
      message: message,
      status: CustomerRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    await document.set(
      request.toFirestore(),
    );

    return request;
  }

  // UPDATE STATUS
  Future<void> updateRequestStatus({
    required String requestId,
    required CustomerRequestStatus status,
  }) async {
    await _requests.doc(requestId).update({
      'status': status.name,
    });
  }

  // CUSTOMER CANCEL
  Future<void> cancelRequest(
      String requestId,
      ) async {
    await _requests.doc(requestId).update({
      'status':
      CustomerRequestStatus.cancelled.name,
    });
  }
}