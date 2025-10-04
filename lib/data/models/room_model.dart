class Room {
  final String id;
  final String hotelId;
  final String roomType;
  final double pricePerNight;
  final String currency;
  final int capacity;
  final String bedType;
  final List<String> amenities;
  final int availableCount;

  Room({
    required this.id,
    required this.hotelId,
    required this.roomType,
    required this.pricePerNight,
    required this.currency,
    required this.capacity,
    required this.bedType,
    required this.amenities,
    required this.availableCount,
  });

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      hotelId: map['hotel_id'] ?? '',
      roomType: map['room_type'] ?? '',
      pricePerNight: (map['price_per_night'] is num)
          ? map['price_per_night'].toDouble()
          : 0.0,
      currency: map['currency'] ?? '',
      capacity: map['capacity'] ?? 0,
      bedType: map['bed_type'] ?? '',
      amenities: (map['amenities'] is List)
          ? List<String>.from(map['amenities'])
          : (map['amenities'] is String)
          ? List<String>.from(map['amenities'].split(','))
          : [],
      availableCount: map['available_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'room_type': roomType,
      'price_per_night': pricePerNight,
      'currency': currency,
      'capacity': capacity,
      'bed_type': bedType,
      'amenities': amenities,
      'available_count': availableCount,
    };
  }
}
