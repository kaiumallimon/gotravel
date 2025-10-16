class PlaceModel {
  final String id;
  final String name;
  final String? description;
  final String country;
  final String? stateProvince;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? category;
  final int popularRanking;
  final int visitCount;
  final double rating;
  final int reviewsCount;
  final String coverImage;
  final List<String> images;
  final String? bestTimeToVisit;
  final String? averageTemperature;
  final String currency;
  final String? localLanguage;
  final String? timeZone;
  final List<String> famousFor;
  final List<String> activities;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlaceModel({
    required this.id,
    required this.name,
    this.description,
    required this.country,
    this.stateProvince,
    this.city,
    this.latitude,
    this.longitude,
    this.category,
    this.popularRanking = 0,
    this.visitCount = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.coverImage,
    this.images = const [],
    this.bestTimeToVisit,
    this.averageTemperature,
    this.currency = 'USD',
    this.localLanguage,
    this.timeZone,
    this.famousFor = const [],
    this.activities = const [],
    this.isFeatured = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  PlaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? country,
    String? stateProvince,
    String? city,
    double? latitude,
    double? longitude,
    String? category,
    int? popularRanking,
    int? visitCount,
    double? rating,
    int? reviewsCount,
    String? coverImage,
    List<String>? images,
    String? bestTimeToVisit,
    String? averageTemperature,
    String? currency,
    String? localLanguage,
    String? timeZone,
    List<String>? famousFor,
    List<String>? activities,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      country: country ?? this.country,
      stateProvince: stateProvince ?? this.stateProvince,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      popularRanking: popularRanking ?? this.popularRanking,
      visitCount: visitCount ?? this.visitCount,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      coverImage: coverImage ?? this.coverImage,
      images: images ?? this.images,
      bestTimeToVisit: bestTimeToVisit ?? this.bestTimeToVisit,
      averageTemperature: averageTemperature ?? this.averageTemperature,
      currency: currency ?? this.currency,
      localLanguage: localLanguage ?? this.localLanguage,
      timeZone: timeZone ?? this.timeZone,
      famousFor: famousFor ?? this.famousFor,
      activities: activities ?? this.activities,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'country': country,
      'state_province': stateProvince,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'popular_ranking': popularRanking,
      'visit_count': visitCount,
      'rating': rating,
      'reviews_count': reviewsCount,
      'cover_image': coverImage,
      'images': images,
      'best_time_to_visit': bestTimeToVisit,
      'average_temperature': averageTemperature,
      'currency': currency,
      'local_language': localLanguage,
      'time_zone': timeZone,
      'famous_for': famousFor,
      'activities': activities,
      'is_featured': isFeatured,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      country: map['country'] ?? '',
      stateProvince: map['state_province'],
      city: map['city'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      category: map['category'],
      popularRanking: map['popular_ranking']?.toInt() ?? 0,
      visitCount: map['visit_count']?.toInt() ?? 0,
      rating: map['rating']?.toDouble() ?? 0.0,
      reviewsCount: map['reviews_count']?.toInt() ?? 0,
      coverImage: map['cover_image'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      bestTimeToVisit: map['best_time_to_visit'],
      averageTemperature: map['average_temperature'],
      currency: map['currency'] ?? 'USD',
      localLanguage: map['local_language'],
      timeZone: map['time_zone'],
      famousFor: List<String>.from(map['famous_for'] ?? []),
      activities: List<String>.from(map['activities'] ?? []),
      isFeatured: map['is_featured'] ?? false,
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'PlaceModel(id: $id, name: $name, country: $country, city: $city, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}