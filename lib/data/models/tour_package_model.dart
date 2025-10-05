import 'package:flutter/foundation.dart';
import 'package_activity_model.dart';
import 'package_date_model.dart';

class TourPackage {
  final String id;
  final String name;
  final String description;
  final String destination;
  final String country;
  final String category;
  final int durationDays;
  final double price;
  final String currency;
  final int maxParticipants;
  final int availableSlots;
  final String? difficultyLevel;
  final int minimumAge;
  final List<String> includedServices;
  final List<String> excludedServices;
  final Map<String, dynamic>? itinerary;
  final String contactEmail;
  final String contactPhone;
  final double rating;
  final int reviewsCount;
  final String coverImage;
  final List<String> images;
  final bool isActive;
  final List<PackageActivity> activities;
  final List<PackageDate> packageDates;

  TourPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.destination,
    required this.country,
    required this.category,
    required this.durationDays,
    required this.price,
    required this.currency,
    required this.maxParticipants,
    required this.availableSlots,
    this.difficultyLevel,
    this.minimumAge = 0,
    required this.includedServices,
    required this.excludedServices,
    this.itinerary,
    required this.contactEmail,
    required this.contactPhone,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.coverImage,
    required this.images,
    this.isActive = true,
    this.activities = const [],
    this.packageDates = const [],
  });

  /// ✅ Create TourPackage from Supabase row
  factory TourPackage.fromMap(Map<String, dynamic> map) {
    return TourPackage(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      destination: map['destination'] ?? '',
      country: map['country'] ?? '',
      category: map['category'] ?? '',
      durationDays: map['duration_days'] ?? 0,
      price: (map['price'] is num) ? map['price'].toDouble() : 0.0,
      currency: map['currency'] ?? 'USD',
      maxParticipants: map['max_participants'] ?? 0,
      availableSlots: map['available_slots'] ?? 0,
      difficultyLevel: map['difficulty_level'],
      minimumAge: map['minimum_age'] ?? 0,
      includedServices: (map['included_services'] is List)
          ? List<String>.from(map['included_services'])
          : [],
      excludedServices: (map['excluded_services'] is List)
          ? List<String>.from(map['excluded_services'])
          : [],
      itinerary: map['itinerary'] is Map<String, dynamic> 
          ? map['itinerary'] 
          : null,
      contactEmail: map['contact_email'] ?? '',
      contactPhone: map['contact_phone'] ?? '',
      rating: (map['rating'] is num) ? map['rating'].toDouble() : 0.0,
      reviewsCount: map['reviews_count'] ?? 0,
      coverImage: map['cover_image'] ?? '',
      images: (map['images'] is List)
          ? List<String>.from(map['images'])
          : [],
      isActive: map['is_active'] ?? true,
      activities: map['package_activities'] != null
          ? (map['package_activities'] as List)
                .map((a) => PackageActivity.fromMap(a as Map<String, dynamic>))
                .toList()
          : [],
      packageDates: () {
        debugPrint('🔍 Package dates in map: ${map['package_dates']}');
        if (map['package_dates'] != null) {
          final dates = (map['package_dates'] as List)
              .map((d) {
                debugPrint('🔍 Processing package date: $d');
                return PackageDate.fromMap(d as Map<String, dynamic>);
              })
              .toList();
          debugPrint('🔍 Parsed ${dates.length} package dates');
          return dates;
        } else {
          debugPrint('🔍 No package_dates found in map keys: ${map.keys}');
          return <PackageDate>[];
        }
      }(),
    );
  }

  /// Convert back to Map (for insert/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'destination': destination,
      'country': country,
      'category': category,
      'duration_days': durationDays,
      'price': price,
      'currency': currency,
      'max_participants': maxParticipants,
      'available_slots': availableSlots,
      'difficulty_level': difficultyLevel,
      'minimum_age': minimumAge,
      'included_services': includedServices,
      'excluded_services': excludedServices,
      'itinerary': itinerary,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'rating': rating,
      'reviews_count': reviewsCount,
      'cover_image': coverImage,
      'images': images,
      'is_active': isActive,
      'package_activities': activities.map((activity) => activity.toMap()).toList(),
      'package_dates': packageDates.map((date) => date.toMap()).toList(),
    };
  }

  /// Get the price display string
  String getPriceDisplay() {
    return '$currency${price.toStringAsFixed(0)}';
  }

  /// Get duration display string
  String getDurationDisplay() {
    if (durationDays == 1) {
      return '$durationDays day';
    }
    return '$durationDays days';
  }

  /// Get next available departure date
  PackageDate? getNextAvailableDate() {
    final now = DateTime.now();
    final availableDates = packageDates
        .where((date) => 
            date.isActive && 
            date.departureDate.isAfter(now) && 
            date.availableSlots > 0)
        .toList();
    
    if (availableDates.isEmpty) return null;
    
    availableDates.sort((a, b) => a.departureDate.compareTo(b.departureDate));
    return availableDates.first;
  }
}