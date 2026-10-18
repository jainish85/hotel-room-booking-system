import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/room_model.dart';

class RoomService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection('rooms');

  // ============================================================
  // CUSTOMER
  //
  // Returns only active rooms.
  // ============================================================

  Stream<List<RoomModel>> watchActiveRooms() {
    return _rooms
        .where(
      'isActive',
      isEqualTo: true,
    )
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs
            .map(
              (doc) => RoomModel.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
            .toList();
      },
    );
  }

  // ============================================================
  // MANAGER / ADMIN
  //
  // Returns ALL rooms, including inactive rooms.
  // ============================================================

  Stream<List<RoomModel>> watchAllRooms() {
    return _rooms.snapshots().map(
          (snapshot) {
        return snapshot.docs
            .map(
              (doc) => RoomModel.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
            .toList();
      },
    );
  }

  // ============================================================
  // GET ALL ROOMS
  // ============================================================

  Future<List<RoomModel>> getAllRooms() async {
    final snapshot = await _rooms.get();

    return snapshot.docs
        .map(
          (doc) => RoomModel.fromFirestore(
        doc.id,
        doc.data(),
      ),
    )
        .toList();
  }

  // ============================================================
  // GET ROOM BY ID
  // ============================================================

  Future<RoomModel?> getRoomById(
      String roomId,
      ) async {
    final document =
    await _rooms.doc(roomId).get();

    if (!document.exists ||
        document.data() == null) {
      return null;
    }

    return RoomModel.fromFirestore(
      document.id,
      document.data()!,
    );
  }

  // ============================================================
  // ADD ROOM
  // ============================================================

  Future<void> addRoom(
      RoomModel room,
      ) async {
    await _rooms.doc(room.id).set(
      room.toFirestore(),
    );
  }

  // ============================================================
  // ADD MULTIPLE ROOMS
  // ============================================================

  Future<void> addRooms(
      List<RoomModel> rooms,
      ) async {
    if (rooms.isEmpty) {
      return;
    }

    final batch =
    _firestore.batch();

    for (final room in rooms) {
      final document =
      _rooms.doc(room.id);

      batch.set(
        document,
        room.toFirestore(),
      );
    }

    await batch.commit();
  }

  // ============================================================
  // UPDATE ROOM
  // ============================================================

  Future<void> updateRoom(
      RoomModel room,
      ) async {
    await _rooms.doc(room.id).update(
      room.toFirestore(),
    );
  }

  // ============================================================
  // DEACTIVATE ROOM
  //
  // Does NOT delete the room.
  // ============================================================

  Future<void> deactivateRoom(
      String roomId,
      ) async {
    await _rooms.doc(roomId).update({
      'isActive': false,
    });
  }

  // ============================================================
  // ACTIVATE ROOM
  // ============================================================

  Future<void> activateRoom(
      String roomId,
      ) async {
    await _rooms.doc(roomId).update({
      'isActive': true,
    });
  }
}