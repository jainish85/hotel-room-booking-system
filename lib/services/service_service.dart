import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_model.dart';

class ServiceService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _services =>
      _firestore.collection('services');

  CollectionReference<Map<String, dynamic>>
  get servicesCollection => _services;

  // ============================================================
  // ACTIVE SERVICES FOR CUSTOMERS
  // ============================================================
  Stream<List<ServiceModel>> watchActiveServices() {
    return _services.snapshots().map(
          (snapshot) {
        final List<ServiceModel> services = [];

        for (final doc in snapshot.docs) {
          final data = doc.data();

          final isActive = data['isActive'] == true;

          if (!isActive) {
            continue;
          }

          try {
            services.add(
              ServiceModel.fromFirestore(
                doc.id,
                data,
              ),
            );
          } catch (_) {
            // Ignore a malformed service document
            // instead of breaking the whole service list.
          }
        }

        return services;
      },
    );
  }

  // ============================================================
  // ALL SERVICES FOR MANAGER / ADMIN
  // ============================================================
  Stream<List<ServiceModel>> watchAllServices() {
    return _services.snapshots().map(
          (snapshot) {
        final List<ServiceModel> services = [];

        for (final doc in snapshot.docs) {
          try {
            services.add(
              ServiceModel.fromFirestore(
                doc.id,
                doc.data(),
              ),
            );
          } catch (_) {
            // Ignore malformed documents.
          }
        }

        return services;
      },
    );
  }

  // ============================================================
  // GET ONE SERVICE
  // ============================================================
  Future<ServiceModel?> getServiceById(
      String serviceId,
      ) async {
    final document =
    await _services.doc(serviceId).get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return ServiceModel.fromFirestore(
      document.id,
      data,
    );
  }

  // ============================================================
  // ADD SERVICE
  // ============================================================
  Future<void> addService(
      ServiceModel service,
      ) async {
    await _services.doc(service.id).set(
      service.toFirestore(),
    );
  }

  // ============================================================
  // UPDATE SERVICE
  // ============================================================
  Future<void> updateService(
      ServiceModel service,
      ) async {
    await _services.doc(service.id).update(
      service.toFirestore(),
    );
  }

  // ============================================================
  // DEACTIVATE SERVICE
  // ============================================================
  Future<void> deactivateService(
      String serviceId,
      ) async {
    await _services.doc(serviceId).update({
      'isActive': false,
    });
  }

  // ============================================================
  // DELETE SERVICE
  // ============================================================
  Future<void> deleteService(
      String serviceId,
      ) async {
    await _services.doc(serviceId).delete();
  }
}