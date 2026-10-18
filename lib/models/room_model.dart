class RoomModel {
  final String id;
  final String roomNumber;
  final String roomType;
  final String roomName;
  final double price;
  final int capacity;
  final String description;
  final List<String> facilities;
  final String imageUrl;
  final RoomStatus status;
  final bool isActive;

  final bool hasParking;
  final double rating;

  // Stores dates already reserved by confirmed/active bookings.
  final List<String> reservedDates;

  const RoomModel({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.roomName,
    required this.price,
    required this.capacity,
    required this.description,
    required this.facilities,
    required this.imageUrl,
    required this.status,
    required this.isActive,
    this.hasParking = false,
    this.rating = 0,
    this.reservedDates = const [],
  });

  factory RoomModel.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return RoomModel(
      id: id,
      roomNumber:
      data['roomNumber'] as String? ?? '',
      roomType:
      data['roomType'] as String? ?? '',
      roomName:
      data['roomName'] as String? ?? '',
      price:
      (data['price'] as num?)?.toDouble() ?? 0,
      capacity:
      (data['capacity'] as num?)?.toInt() ?? 1,
      description:
      data['description'] as String? ?? '',
      facilities:
      List<String>.from(
        data['facilities'] as List? ?? [],
      ),
      imageUrl:
      data['imageUrl'] as String? ?? '',
      status:
      _statusFromString(
        data['status'] as String? ??
            'available',
      ),
      isActive:
      data['isActive'] as bool? ?? true,

      hasParking:
      data['hasParking'] as bool? ?? false,

      rating:
      (data['rating'] as num?)?.toDouble() ?? 0,

      reservedDates:
      List<String>.from(
        data['reservedDates'] as List? ?? [],
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roomNumber': roomNumber,
      'roomType': roomType,
      'roomName': roomName,
      'price': price,
      'capacity': capacity,
      'description': description,
      'facilities': facilities,
      'imageUrl': imageUrl,
      'status': status.name,
      'isActive': isActive,

      'hasParking': hasParking,
      'rating': rating,

      // Preserve booking occupancy dates.
      'reservedDates': reservedDates,
    };
  }

  static RoomStatus _statusFromString(
      String status,
      ) {
    switch (status) {
      case 'booked':
        return RoomStatus.booked;

      case 'occupied':
        return RoomStatus.occupied;

      case 'cleaning':
        return RoomStatus.cleaning;

      case 'maintenance':
        return RoomStatus.maintenance;

      default:
        return RoomStatus.available;
    }
  }
}

enum RoomStatus {
  available,
  booked,
  occupied,
  cleaning,
  maintenance,
}