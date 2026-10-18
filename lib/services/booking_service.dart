import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_model.dart';
import '../models/room_model.dart';

class BookingService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection('rooms');

  CollectionReference<Map<String, dynamic>>
  get _roomReservations =>
      _firestore.collection('room_reservations');

  // ============================================================
  // CUSTOMER BOOKINGS
  // ============================================================

  Stream<List<BookingModel>> watchCustomerBookings(
      String customerId,
      ) {
    return _bookings
        .where(
      'customerId',
      isEqualTo: customerId,
    )
        .snapshots()
        .map(
          (snapshot) {
        final bookings = snapshot.docs
            .map(
              (doc) => BookingModel.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
            .toList();

        bookings.sort(
              (a, b) => b.checkIn.compareTo(
            a.checkIn,
          ),
        );

        return bookings;
      },
    );
  }

  // ============================================================
  // ALL BOOKINGS
  // MANAGER / ADMIN
  // ============================================================

  Stream<List<BookingModel>> watchAllBookings() {
    return _bookings.snapshots().map(
          (snapshot) {
        final bookings = snapshot.docs
            .map(
              (doc) => BookingModel.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
            .toList();

        bookings.sort(
              (a, b) => b.checkIn.compareTo(
            a.checkIn,
          ),
        );

        return bookings;
      },
    );
  }

  // ============================================================
  // DATE KEY
  // ============================================================

  String _dateKey(
      DateTime date,
      ) {
    final month =
    date.month.toString().padLeft(
      2,
      '0',
    );

    final day =
    date.day.toString().padLeft(
      2,
      '0',
    );

    return '${date.year}-$month-$day';
  }

  // ============================================================
  // STAY DATE KEYS
  //
  // Check-in is included.
  // Check-out is excluded.
  //
  // Example:
  // 10 -> 12
  // reserves:
  // 10
  // 11
  // ============================================================

  List<String> _dateKeysForStay({
    required DateTime checkIn,
    required DateTime checkOut,
  }) {
    final dates = <String>[];

    var currentDate = DateTime(
      checkIn.year,
      checkIn.month,
      checkIn.day,
    );

    final lastDate = DateTime(
      checkOut.year,
      checkOut.month,
      checkOut.day,
    );

    while (currentDate.isBefore(
      lastDate,
    )) {
      dates.add(
        _dateKey(currentDate),
      );

      currentDate = currentDate.add(
        const Duration(days: 1),
      );
    }

    return dates;
  }

  // ============================================================
  // RESERVATION DOCUMENT ID
  // ============================================================

  String _reservationId({
    required String roomId,
    required String dateKey,
  }) {
    return '${roomId}_$dateKey';
  }

  // ============================================================
  // CHECK ROOM AVAILABILITY
  // ============================================================

  Future<bool> isRoomAvailable({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeBookingId,
  }) async {
    if (!checkOut.isAfter(
      checkIn,
    )) {
      return false;
    }

    final roomDocument =
    await _rooms.doc(roomId).get();

    if (!roomDocument.exists ||
        roomDocument.data() == null) {
      return false;
    }

    final room =
    RoomModel.fromFirestore(
      roomDocument.id,
      roomDocument.data()!,
    );

    if (!room.isActive) {
      return false;
    }

    final dateKeys =
    _dateKeysForStay(
      checkIn: checkIn,
      checkOut: checkOut,
    );

    for (final dateKey in dateKeys) {
      final reservationDocument =
      await _roomReservations
          .doc(
        _reservationId(
          roomId: roomId,
          dateKey: dateKey,
        ),
      )
          .get();

      if (!reservationDocument.exists) {
        continue;
      }

      final data =
      reservationDocument.data();

      if (data == null) {
        continue;
      }

      final bookingId =
          data['bookingId'] as String? ??
              '';

      if (excludeBookingId != null &&
          bookingId ==
              excludeBookingId) {
        continue;
      }

      return false;
    }

    return true;
  }

  // ============================================================
  // CREATE BOOKING
  //
  // Booking document and reservation documents are created
  // atomically in one Firestore transaction.
  // ============================================================

  Future<BookingModel?> createBooking({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String roomId,
    required String roomNumber,
    required String roomName,
    required DateTime checkIn,
    required DateTime checkOut,
    int? guests,
    int adults = 1,
    int children = 0,
    List<int> childAges = const [],
    required double roomPrice,
  }) async {
    if (!checkOut.isAfter(
      checkIn,
    )) {
      return null;
    }

    if (adults <= 0) {
      return null;
    }

    if (children < 0) {
      return null;
    }

    if (children != childAges.length) {
      return null;
    }

    for (final age in childAges) {
      if (age < 4 || age > 15) {
        return null;
      }
    }

    final totalGuests =
        adults + children;

    if (totalGuests <= 0) {
      return null;
    }

    final dateKeys =
    _dateKeysForStay(
      checkIn: checkIn,
      checkOut: checkOut,
    );

    if (dateKeys.isEmpty) {
      return null;
    }

    final bookingDocument =
    _bookings.doc();

    try {
      final booking =
      await _firestore.runTransaction<
          BookingModel>(
            (transaction) async {
          // ----------------------------------------------------
          // READ ROOM
          // ----------------------------------------------------

          final roomDocument =
          await transaction.get(
            _rooms.doc(roomId),
          );

          if (!roomDocument.exists ||
              roomDocument.data() == null) {
            throw _RoomUnavailableException();
          }

          final room =
          RoomModel.fromFirestore(
            roomDocument.id,
            roomDocument.data()!,
          );

          if (!room.isActive) {
            throw _RoomUnavailableException();
          }

          if (totalGuests >
              room.capacity) {
            throw _RoomCapacityException();
          }

          // ----------------------------------------------------
          // READ ALL RESERVATION DOCUMENTS
          // BEFORE ANY WRITES.
          // ----------------------------------------------------

          final reservationDocuments =
          <String,
              DocumentSnapshot<
                  Map<String, dynamic>>> {};

          for (final dateKey in dateKeys) {
            final reservationReference =
            _roomReservations.doc(
              _reservationId(
                roomId: roomId,
                dateKey: dateKey,
              ),
            );

            final reservationSnapshot =
            await transaction.get(
              reservationReference,
            );

            reservationDocuments[
            dateKey] =
                reservationSnapshot;
          }

          // ----------------------------------------------------
          // CHECK FOR CONFLICT
          // ----------------------------------------------------

          for (final dateKey in dateKeys) {
            final reservationSnapshot =
            reservationDocuments[
            dateKey]!;

            if (reservationSnapshot.exists) {
              throw _RoomUnavailableException();
            }
          }

          // ----------------------------------------------------
          // BOOKING CALCULATION
          // ----------------------------------------------------

          final nights =
              checkOut
                  .difference(
                checkIn,
              )
                  .inDays;

          if (nights <= 0) {
            throw _InvalidBookingException();
          }

          // Always use the current Firestore room price.
          final actualRoomPrice =
              room.price;

          final totalAmount =
              actualRoomPrice * nights;

          final actualGuests =
          guests != null &&
              adults == 1 &&
              children == 0
              ? guests
              : totalGuests;

          if (actualGuests <= 0 ||
              actualGuests >
                  room.capacity) {
            throw _RoomCapacityException();
          }

          final booking =
          BookingModel(
            id:
            bookingDocument.id,
            customerId:
            customerId,
            customerName:
            customerName,
            customerPhone:
            customerPhone,
            roomId:
            room.id,
            roomNumber:
            room.roomNumber,
            roomName:
            room.roomName,
            checkIn:
            checkIn,
            checkOut:
            checkOut,
            guests:
            actualGuests,
            adults:
            adults,
            children:
            children,
            childAges:
            childAges,
            roomPrice:
            actualRoomPrice,
            totalAmount:
            totalAmount,
            status:
            BookingStatus.confirmed,
            createdAt:
            DateTime.now(),
          );

          // ----------------------------------------------------
          // CREATE BOOKING
          // ----------------------------------------------------

          transaction.set(
            bookingDocument,
            booking.toFirestore(),
          );

          // ----------------------------------------------------
          // CREATE ONE RESERVATION LOCK FOR EACH STAY DATE
          // ----------------------------------------------------

          for (final dateKey in dateKeys) {
            final reservationReference =
            _roomReservations.doc(
              _reservationId(
                roomId: roomId,
                dateKey: dateKey,
              ),
            );

            transaction.set(
              reservationReference,
              {
                'roomId': room.id,
                'roomNumber':
                room.roomNumber,
                'bookingId':
                booking.id,
                'customerId':
                customerId,
                'date':
                dateKey,
              },
            );
          }

          return booking;
        },
      );

      return booking;
    } on _RoomUnavailableException {
      return null;
    } on _RoomCapacityException {
      return null;
    } on _InvalidBookingException {
      return null;
    }
  }

  // ============================================================
  // CANCEL BOOKING
  //
  // Updates the booking to cancelled and removes its
  // reservation locks atomically.
  // ============================================================

  Future<void> cancelBooking(
      String bookingId,
      ) async {
    final bookingDocument =
    _bookings.doc(
      bookingId,
    );

    await _firestore.runTransaction(
          (transaction) async {
        final bookingSnapshot =
        await transaction.get(
          bookingDocument,
        );

        if (!bookingSnapshot.exists ||
            bookingSnapshot.data() ==
                null) {
          throw Exception(
            'Booking not found.',
          );
        }

        final booking =
        BookingModel.fromFirestore(
          bookingSnapshot.id,
          bookingSnapshot.data()!,
        );

        if (booking.status ==
            BookingStatus.cancelled) {
          return;
        }

        final dateKeys =
        _dateKeysForStay(
          checkIn:
          booking.checkIn,
          checkOut:
          booking.checkOut,
        );

        final reservationSnapshots =
        <DocumentReference<
            Map<String, dynamic>>,
            DocumentSnapshot<
                Map<String, dynamic>>>{};

        // --------------------------------------------------------
        // READ RESERVATIONS
        // --------------------------------------------------------

        for (final dateKey in dateKeys) {
          final reservationReference =
          _roomReservations.doc(
            _reservationId(
              roomId:
              booking.roomId,
              dateKey:
              dateKey,
            ),
          );

          final reservationSnapshot =
          await transaction.get(
            reservationReference,
          );

          reservationSnapshots[
          reservationReference] =
              reservationSnapshot;
        }

        // --------------------------------------------------------
        // UPDATE BOOKING STATUS
        // --------------------------------------------------------

        transaction.update(
          bookingDocument,
          {
            'status':
            BookingStatus.cancelled.name,
          },
        );

        // --------------------------------------------------------
        // DELETE ONLY RESERVATIONS BELONGING TO THIS BOOKING
        // --------------------------------------------------------

        for (final entry
        in reservationSnapshots.entries) {
          final reservation =
              entry.value;

          if (!reservation.exists) {
            continue;
          }

          final data =
          reservation.data();

          if (data == null) {
            continue;
          }

          if (data['bookingId'] ==
              bookingId) {
            transaction.delete(
              entry.key,
            );
          }
        }
      },
    );
  }

  // ============================================================
  // UPDATE BOOKING STATUS
  // ============================================================

  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    if (status ==
        BookingStatus.cancelled) {
      await cancelBooking(
        bookingId,
      );
      return;
    }

    await _bookings
        .doc(bookingId)
        .update({
      'status': status.name,
    });
  }
}

// ============================================================
// INTERNAL EXCEPTIONS
// ============================================================

class _RoomUnavailableException
    implements Exception {}

class _RoomCapacityException
    implements Exception {}

class _InvalidBookingException
    implements Exception {}