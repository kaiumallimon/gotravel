import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotravel/data/services/ai/weather_tool.dart';

/// Predefined Travel Tools - Simple, reliable, and specific
/// AI will select the appropriate tool based on user query
class TravelTools {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID if authenticated
  static String? get _userId => _supabase.auth.currentUser?.id;

  // ============================================================================
  // PACKAGE TOOLS
  // ============================================================================

  /// Tool 1: Get cheapest available packages
  static Future<Map<String, dynamic>> getCheapestPackages({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .gt('available_slots', 0)
          .order('price', ascending: true)
          .limit(limit);

      return {
        'success': true,
        'tool': 'cheapest_packages',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'cheapest_packages', 'error': e.toString()};
    }
  }

  /// Tool 2: Get most expensive/premium packages
  static Future<Map<String, dynamic>> getPremiumPackages({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .gt('available_slots', 0)
          .order('price', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'tool': 'premium_packages',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'premium_packages', 'error': e.toString()};
    }
  }

  /// Tool 3: Get top-rated packages
  static Future<Map<String, dynamic>> getTopRatedPackages({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .gt('available_slots', 0)
          .order('rating', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'tool': 'top_rated_packages',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'top_rated_packages', 'error': e.toString()};
    }
  }

  /// Tool 4: Get beach packages
  static Future<Map<String, dynamic>> getBeachPackages({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .eq('category', 'Beach')
          .gt('available_slots', 0)
          .order('rating', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'tool': 'beach_packages',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'beach_packages', 'error': e.toString()};
    }
  }

  /// Tool 5: Get mountain/hill packages
  static Future<Map<String, dynamic>> getMountainPackages({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .or('category.eq.Adventure,category.eq.Mountain')
          .gt('available_slots', 0)
          .order('rating', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'tool': 'mountain_packages',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'mountain_packages', 'error': e.toString()};
    }
  }

  /// Tool 6: Get wildlife/nature packages
  static Future<Map<String, dynamic>> getWildlifePackages({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .or('category.eq.Wildlife,category.eq.Nature')
          .gt('available_slots', 0)
          .order('rating', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'tool': 'wildlife_packages',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'wildlife_packages', 'error': e.toString()};
    }
  }

  /// Tool 7: Get cultural/heritage packages
  static Future<Map<String, dynamic>> getCulturalPackages({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .eq('category', 'Cultural')
          .gt('available_slots', 0)
          .order('rating', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'tool': 'cultural_packages',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'cultural_packages', 'error': e.toString()};
    }
  }

  /// Tool 8: Get beginner-friendly packages (easy difficulty)
  static Future<Map<String, dynamic>> getBeginnerPackages({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .eq('difficulty_level', 'Easy')
          .gt('available_slots', 0)
          .order('price', ascending: true)
          .limit(limit);

      return {
        'success': true,
        'tool': 'beginner_packages',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'beginner_packages', 'error': e.toString()};
    }
  }

  /// Tool 9: Get weekend packages (1-3 days)
  static Future<Map<String, dynamic>> getWeekendPackages({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .lte('duration_days', 3)
          .gt('available_slots', 0)
          .order('rating', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'tool': 'weekend_packages',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'weekend_packages', 'error': e.toString()};
    }
  }

  /// Tool 10: Get long vacation packages (7+ days)
  static Future<Map<String, dynamic>> getLongVacationPackages({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .gte('duration_days', 7)
          .gt('available_slots', 0)
          .order('rating', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'tool': 'long_vacation_packages',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'long_vacation_packages', 'error': e.toString()};
    }
  }

  /// Tool 11: Get packages by destination
  static Future<Map<String, dynamic>> getPackagesByDestination(String destination) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .ilike('destination', '%$destination%')
          .gt('available_slots', 0)
          .order('rating', ascending: false)
          .limit(10);

      return {
        'success': true,
        'tool': 'packages_by_destination',
        'data': response,
        'count': (response as List).length,
        'destination': destination,
      };
    } catch (e) {
      return {'success': false, 'tool': 'packages_by_destination', 'error': e.toString()};
    }
  }

  /// Tool 12: Get budget packages (under $200)
  static Future<Map<String, dynamic>> getBudgetPackages({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('packages')
          .select()
          .eq('is_active', true)
          .lt('price', 200)
          .gt('available_slots', 0)
          .order('price', ascending: true)
          .limit(limit);

      return {
        'success': true,
        'tool': 'budget_packages',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'budget_packages', 'error': e.toString()};
    }
  }

  // ============================================================================
  // USER-SPECIFIC TOOLS (Requires Authentication)
  // ============================================================================

  /// Tool 13: Get user's favorite packages
  static Future<Map<String, dynamic>> getMyFavoritePackages() async {
    try {
      if (_userId == null) {
        return {'success': false, 'tool': 'my_favorites', 'error': 'Please login first'};
      }

      final response = await _supabase
          .from('user_favorites')
          .select('*, packages(*)')
          .eq('user_id', _userId!)
          .eq('item_type', 'package')
          .order('created_at', ascending: false)
          .limit(10);

      return {
        'success': true,
        'tool': 'my_favorites',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'my_favorites', 'error': e.toString()};
    }
  }

  /// Tool 14: Get user's bookings
  static Future<Map<String, dynamic>> getMyBookings() async {
    try {
      if (_userId == null) {
        return {'success': false, 'tool': 'my_bookings', 'error': 'Please login first'};
      }

      final response = await _supabase
          .from('bookings')
          .select('*, packages(*)')
          .eq('user_id', _userId!)
          .order('created_at', ascending: false)
          .limit(10);

      return {
        'success': true,
        'tool': 'my_bookings',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'my_bookings', 'error': e.toString()};
    }
  }

  /// Tool 15: Get user's upcoming bookings
  static Future<Map<String, dynamic>> getMyUpcomingBookings() async {
    try {
      if (_userId == null) {
        return {'success': false, 'tool': 'upcoming_bookings', 'error': 'Please login first'};
      }

      final response = await _supabase
          .from('bookings')
          .select('*, packages(*)')
          .eq('user_id', _userId!)
          .eq('status', 'confirmed')
          .gte('booking_date', DateTime.now().toIso8601String())
          .order('booking_date', ascending: true)
          .limit(10);

      return {
        'success': true,
        'tool': 'upcoming_bookings',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'upcoming_bookings', 'error': e.toString()};
    }
  }

  /// Tool 16: Get user's search history
  static Future<Map<String, dynamic>> getMySearchHistory() async {
    try {
      if (_userId == null) {
        return {'success': false, 'tool': 'search_history', 'error': 'Please login first'};
      }

      final response = await _supabase
          .from('search_history')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false)
          .limit(10);

      return {
        'success': true,
        'tool': 'search_history',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'search_history', 'error': e.toString()};
    }
  }

  // ============================================================================
  // PLACE TOOLS
  // ============================================================================

  /// Tool 17: Get popular tourist places
  static Future<Map<String, dynamic>> getPopularPlaces({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('places')
          .select()
          .eq('is_active', true)
          .order('rating', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'tool': 'popular_places',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'popular_places', 'error': e.toString()};
    }
  }

  /// Tool 18: Get places by category
  static Future<Map<String, dynamic>> getPlacesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('places')
          .select()
          .eq('is_active', true)
          .ilike('category', '%$category%')
          .order('rating', ascending: false)
          .limit(10);

      return {
        'success': true,
        'tool': 'places_by_category',
        'data': response,
        'count': (response as List).length,
        'category': category,
      };
    } catch (e) {
      return {'success': false, 'tool': 'places_by_category', 'error': e.toString()};
    }
  }

  // ============================================================================
  // HOTEL TOOLS
  // ============================================================================

  /// Tool 19: Get top-rated hotels
  static Future<Map<String, dynamic>> getTopRatedHotels({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('hotels')
          .select()
          .order('rating', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'tool': 'top_hotels',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'top_hotels', 'error': e.toString()};
    }
  }

  /// Tool 20: Get hotels by city
  static Future<Map<String, dynamic>> getHotelsByCity(String city) async {
    try {
      final response = await _supabase
          .from('hotels')
          .select()
          .ilike('city', '%$city%')
          .order('rating', ascending: false)
          .limit(10);

      return {
        'success': true,
        'tool': 'hotels_by_city',
        'data': response,
        'count': (response as List).length,
        'city': city,
      };
    } catch (e) {
      return {'success': false, 'tool': 'hotels_by_city', 'error': e.toString()};
    }
  }

  // ============================================================================
  // WEATHER TOOLS
  // ============================================================================

  /// Tool 21: Get weather for a location
  static Future<Map<String, dynamic>> getWeather(String location) async {
    try {
      final weatherData = await WeatherTool.getCurrentWeather(location);
      
      if (weatherData['success'] == true) {
        return {
          'success': true,
          'tool': 'weather',
          'data': weatherData,
          'location': location,
        };
      } else {
        return {
          'success': false,
          'tool': 'weather',
          'error': weatherData['error'] ?? 'Failed to fetch weather',
        };
      }
    } catch (e) {
      return {'success': false, 'tool': 'weather', 'error': e.toString()};
    }
  }

  /// Tool 22: Get AI recommendations based on user preferences
  static Future<Map<String, dynamic>> getRecommendationsForUser() async {
    try {
      if (_userId == null) {
        return {'success': false, 'tool': 'recommendations', 'error': 'Please login first'};
      }

      final response = await _supabase
          .from('recommendations')
          .select('*, packages(*)')
          .eq('user_id', _userId!)
          .order('score', ascending: false)
          .limit(5);

      return {
        'success': true,
        'tool': 'recommendations',
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {'success': false, 'tool': 'recommendations', 'error': e.toString()};
    }
  }

  // ============================================================================
  // HELPER: Get all available tools list for AI
  // ============================================================================

  static String getAvailableToolsList() {
    return '''
Available Travel Tools:

PACKAGE QUERIES:
1. cheapest_packages - Show most affordable tour packages
2. premium_packages - Show luxury/expensive packages
3. top_rated_packages - Show highest-rated packages
4. beach_packages - Show beach and coastal packages
5. mountain_packages - Show mountain/hill/adventure packages
6. wildlife_packages - Show wildlife and nature packages
7. cultural_packages - Show cultural and heritage packages
8. beginner_packages - Show easy, beginner-friendly packages
9. weekend_packages - Show short 1-3 day packages
10. long_vacation_packages - Show 7+ day packages
11. packages_by_destination - Search packages by destination name
12. budget_packages - Show packages under \$200

USER-SPECIFIC (Requires Login):
13. my_favorites - Show user's favorite packages
14. my_bookings - Show user's all bookings
15. upcoming_bookings - Show user's upcoming trips
16. search_history - Show user's recent searches

PLACES:
17. popular_places - Show popular tourist places
18. places_by_category - Search places by category

HOTELS:
19. top_hotels - Show top-rated hotels
20. hotels_by_city - Search hotels by city name

WEATHER:
21. weather - Get current weather for any location

PERSONALIZED:
22. recommendations - Get AI-based package recommendations
''';
  }
}
