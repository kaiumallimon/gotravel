import 'package:supabase_flutter/supabase_flutter.dart';

class TravelDataTool {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Search for cheapest packages
  static Future<Map<String, dynamic>> getCheapestPackages({
    String? country,
    String? destination,
    int limit = 5,
  }) async {
    try {
      var query = _supabase
          .from('packages')
          .select('id, name, destination, country, price, duration_days, is_active')
          .eq('is_active', true);

      if (country != null && country.isNotEmpty) {
        query = query.filter('country', 'ilike', '%$country%');
      }

      if (destination != null && destination.isNotEmpty) {
        query = query.filter('destination', 'ilike', '%$destination%');
      }

      final response = await query
          .order('price', ascending: true)
          .limit(limit);

      return {
        'success': true,
        'packages': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to fetch packages: $e',
      };
    }
  }

  /// Search for packages by destination
  static Future<Map<String, dynamic>> searchPackages(String searchTerm) async {
    try {
      final response = await _supabase
          .from('packages')
          .select('id, name, destination, country, price_per_person, duration_days, description')
          .eq('is_active', true)
          .or('name.ilike.%$searchTerm%,destination.ilike.%$searchTerm%,country.ilike.%$searchTerm%')
          .limit(10);

      return {
        'success': true,
        'packages': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to search packages: $e',
      };
    }
  }

  /// Get popular places
  static Future<Map<String, dynamic>> getPopularPlaces({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('places')
          .select('id, name, city, country, category, description')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'places': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to fetch places: $e',
      };
    }
  }

  /// Search places by category or location
  static Future<Map<String, dynamic>> searchPlaces(String searchTerm) async {
    try {
      final response = await _supabase
          .from('places')
          .select('id, name, city, country, category, description')
          .eq('is_active', true)
          .or('name.ilike.%$searchTerm%,city.ilike.%$searchTerm%,country.ilike.%$searchTerm%,category.ilike.%$searchTerm%')
          .limit(10);

      return {
        'success': true,
        'places': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to search places: $e',
      };
    }
  }

  /// Get available hotels
  static Future<Map<String, dynamic>> searchHotels({
    String? city,
    String? country,
    int limit = 5,
  }) async {
    try {
      var query = _supabase
          .from('hotels')
          .select('id, name, city, country, rating, reviews_count')
          .eq('is_active', true);

      if (city != null && city.isNotEmpty) {
        query = query.filter('city', 'ilike', '%$city%');
      }

      if (country != null && country.isNotEmpty) {
        query = query.filter('country', 'ilike', '%$country%');
      }

      final response = await query
          .order('rating', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'hotels': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to fetch hotels: $e',
      };
    }
  }

  /// Format package data for AI
  static String formatPackagesForAI(Map<String, dynamic> data) {
    if (data['success'] == false) {
      return data['error'];
    }

    final List packages = data['packages'];
    if (packages.isEmpty) {
      return 'No packages found matching your criteria.';
    }

    StringBuffer result = StringBuffer();
    result.writeln('Found ${data['count']} package(s):\n');

    for (var pkg in packages) {
      result.writeln('📦 ${pkg['name']}');
      result.writeln('   📍 ${pkg['destination']}, ${pkg['country']}');
      result.writeln('   💰 \$${pkg['price']} per person');
      result.writeln('   ⏱️ ${pkg['duration_days']} days');
      if (pkg['description'] != null) {
        result.writeln('   ℹ️ ${pkg['description'].toString().substring(0, pkg['description'].toString().length > 100 ? 100 : pkg['description'].toString().length)}...');
      }
      result.writeln();
    }

    return result.toString();
  }

  /// Format places data for AI
  static String formatPlacesForAI(Map<String, dynamic> data) {
    if (data['success'] == false) {
      return data['error'];
    }

    final List places = data['places'];
    if (places.isEmpty) {
      return 'No places found matching your criteria.';
    }

    StringBuffer result = StringBuffer();
    result.writeln('Found ${data['count']} place(s):\n');

    for (var place in places) {
      result.writeln('🏞️ ${place['name']}');
      result.writeln('   📍 ${place['city']}, ${place['country']}');
      result.writeln('   🏷️ ${place['category']}');
      if (place['description'] != null) {
        result.writeln('   ℹ️ ${place['description'].toString().substring(0, place['description'].toString().length > 100 ? 100 : place['description'].toString().length)}...');
      }
      result.writeln();
    }

    return result.toString();
  }

  /// Format hotels data for AI
  static String formatHotelsForAI(Map<String, dynamic> data) {
    if (data['success'] == false) {
      return data['error'];
    }

    final List hotels = data['hotels'];
    if (hotels.isEmpty) {
      return 'No hotels found matching your criteria.';
    }

    StringBuffer result = StringBuffer();
    result.writeln('Found ${data['count']} hotel(s):\n');

    for (var hotel in hotels) {
      result.writeln('🏨 ${hotel['name']}');
      result.writeln('   📍 ${hotel['city']}, ${hotel['country']}');
      result.writeln('   ⭐ ${hotel['rating']}/5.0 (${hotel['reviews_count']} reviews)');
      result.writeln();
    }

    return result.toString();
  }
}
