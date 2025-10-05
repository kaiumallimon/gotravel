import 'room_model.dart';

class Hotel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String contactEmail;
  final String phone;
  final double rating;
  final int reviewsCount;
  final String coverImage;
  final List<String> images;
  final List<Room> rooms;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.contactEmail,
    required this.phone,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.coverImage,
    required this.images,
    this.rooms = const [],
  });

  /// ✅ Create Hotel from Supabase row
  factory Hotel.fromMap(Map<String, dynamic> map) {
    return Hotel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      latitude: (map['latitude'] is num) ? map['latitude'].toDouble() : 0.0,
      longitude: (map['longitude'] is num) ? map['longitude'].toDouble() : 0.0,
      contactEmail: map['contact_email'] ?? '',
      phone: map['phone'] ?? '',
      rating: (map['rating'] is num) ? map['rating'].toDouble() : 0.0,
      reviewsCount: map['reviews_count'] ?? 0,
      coverImage: map['cover_image'] ?? '',
      images: (map['images'] is List)
          ? List<String>.from(map['images'])
          : (map['images'] is String)
          ? List<String>.from(map['images'].split(','))
          : [],
      rooms: map['rooms'] != null
          ? (map['rooms'] as List)
                .map((r) => Room.fromMap(r as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  /// Convert back to Map (for insert/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'contact_email': contactEmail,
      'phone': phone,
      'rating': rating,
      'reviews_count': reviewsCount,
      'cover_image': coverImage,
      'images': images,
      'rooms': rooms.map((room) => room.toMap()).toList(),
    };
  }
}
