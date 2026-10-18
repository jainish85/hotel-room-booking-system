import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_request_model.dart';

class ServiceRequestService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
  get _requests =>
      _firestore.collection('service_requests');

  // CUSTOMER REQUESTS
  Stream<List<ServiceRequestModel>>
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
              ServiceRequestModel
                  .fromFirestore(
                doc.id,
                doc.data(),
              ),
        )
            .toList();

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

        return requests;
      },
    );
  }

  // ALL REQUESTS
  Stream<List<ServiceRequestModel>>
  watchAllRequests() {
    return _requests.snapshots().map(
          (snapshot) {
        final requests = snapshot.docs
            .map(
              (doc) =>
              ServiceRequestModel
                  .fromFirestore(
                doc.id,
                doc.data(),
              ),
        )
            .toList();

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

        return requests;
      },
    );
  }

  // CREATE
  Future<ServiceRequestModel>
  createRequest({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String serviceType,
    required String description,
    String? bookingId,
  }) async {
    final document = _requests.doc();

    final request =
    ServiceRequestModel(
      id: document.id,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      serviceType: serviceType,
      description: description,
      bookingId: bookingId,
      status:
      ServiceRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    await document.set(
      request.toFirestore(),
    );

    return request;
  }

  // CUSTOMER CANCEL
  Future<void> cancelRequest(
      String requestId,
      ) async {
    await _requests
        .doc(requestId)
        .update({
      'status':
      ServiceRequestStatus
          .cancelled
          .name,
    });
  }

  // MANAGER / ADMIN UPDATE
  Future<void> updateRequestStatus({
    required String requestId,
    required ServiceRequestStatus status,
  }) async {
    await _requests
        .doc(requestId)
        .update({
      'status': status.name,
    });
  }
}