import 'package:supabase_flutter/supabase_flutter.dart';

/// Universal Database Tool - Gives AI access to all database tables
class DatabaseTool {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current authenticated user ID
  static String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// Get current user email
  static String? getCurrentUserEmail() {
    return _supabase.auth.currentUser?.email;
  }

  /// Execute a flexible database query based on AI intent
  static Future<Map<String, dynamic>> query({
    required String table,
    List<String>? columns,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic query = _supabase.from(table).select(columns?.join(', ') ?? '*');

      // Apply filters
      if (filters != null) {
        filters.forEach((key, value) {
          if (value is List) {
            query = query.inFilter(key, value);
          } else if (value is String && value.startsWith('%')) {
            query = query.ilike(key, value);
          } else {
            query = query.eq(key, value);
          }
        });
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return {
        'success': true,
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Search packages
  static Future<Map<String, dynamic>> searchPackages({
    String? destination,
    String? country,
    String? category,
    double? maxPrice,
    double? minRating,
    int? maxDuration,
    int limit = 10,
  }) async {
    try {
      var query = _supabase
          .from('packages')
          .select()
          .eq('is_active', true);

      if (destination != null) {
        query = query.ilike('destination', '%$destination%');
      }

      if (country != null) {
        query = query.ilike('country', '%$country%');
      }

      if (category != null) {
        query = query.ilike('category', '%$category%');
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      if (maxDuration != null) {
        query = query.lte('duration_days', maxDuration);
      }

      final response = await query
          .order('price', ascending: true)
          .limit(limit);

      return {
        'success': true,
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Search places
  static Future<Map<String, dynamic>> searchPlaces({
    String? search,
    String? city,
    String? country,
    String? category,
    int limit = 10,
  }) async {
    try {
      var query = _supabase
          .from('places')
          .select()
          .eq('is_active', true);

      if (search != null) {
        query = query.or('name.ilike.%$search%,description.ilike.%$search%');
      }

      if (city != null) {
        query = query.ilike('city', '%$city%');
      }

      if (country != null) {
        query = query.ilike('country', '%$country%');
      }

      if (category != null) {
        query = query.ilike('category', '%$category%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Search hotels
  static Future<Map<String, dynamic>> searchHotels({
    String? search,
    String? city,
    String? country,
    double? minRating,
    int limit = 10,
  }) async {
    try {
      var query = _supabase
          .from('hotels')
          .select()
          .eq('is_active', true);

      if (search != null) {
        query = query.or('name.ilike.%$search%,description.ilike.%$search%');
      }

      if (city != null) {
        query = query.ilike('city', '%$city%');
      }

      if (country != null) {
        query = query.ilike('country', '%$country%');
      }

      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      final response = await query
          .order('rating', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get user bookings
  static Future<Map<String, dynamic>> getUserBookings({
    String? status,
    int limit = 10,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'User not authenticated',
        };
      }

      var query = _supabase
          .from('bookings')
          .select('''
            *,
            packages:package_id (
              name,
              destination,
              country,
              duration_days,
              price
            )
          ''')
          .eq('user_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get user favorites
  static Future<Map<String, dynamic>> getUserFavorites({
    String? itemType,
    int limit = 20,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'User not authenticated',
        };
      }

      var query = _supabase
          .from('user_favorites')
          .select()
          .eq('user_id', userId);

      if (itemType != null) {
        query = query.eq('item_type', itemType);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'data': response,
        'count': (response as List).length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'User not authenticated',
        };
      }

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get package details with reviews
  static Future<Map<String, dynamic>> getPackageDetails(String packageId) async {
    try {
      final response = await _supabase
          .from('packages')
          .select('''
            *,
            reviews (
              id,
              rating,
              comment,
              created_at,
              users:user_id (
                full_name,
                email
              )
            )
          ''')
          .eq('id', packageId)
          .single();

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Format data for AI consumption
  static String formatForAI(Map<String, dynamic> data, String context) {
    if (data['success'] == false) {
      return 'Error: ${data['error']}';
    }

    final items = data['data'];
    final count = data['count'];

    if (items is List && items.isEmpty) {
      return 'No results found for your query.';
    }

    StringBuffer result = StringBuffer();
    result.writeln('Found ${count ?? 1} result(s):\n');

    if (items is List) {
      for (var item in items) {
        result.writeln(_formatItem(item, context));
        result.writeln();
      }
    } else {
      result.writeln(_formatItem(items, context));
    }

    return result.toString();
  }

  static String _formatItem(Map<String, dynamic> item, String context) {
    switch (context) {
      case 'packages':
        return '''
📦 ${item['name']}
   📍 ${item['destination']}, ${item['country']}
   💰 \$${item['price']} (${item['currency'] ?? 'USD'})
   ⏱️ ${item['duration_days']} days
   ⭐ ${item['rating']}/5.0 (${item['reviews_count']} reviews)
   👥 Max ${item['max_participants']} participants
   📊 Available slots: ${item['available_slots']}''';

      case 'places':
        return '''
🏞️ ${item['name']}
   📍 ${item['city']}, ${item['country']}
   🏷️ ${item['category']}
   ℹ️ ${_truncate(item['description'], 100)}''';

      case 'hotels':
        return '''
🏨 ${item['name']}
   📍 ${item['city']}, ${item['country']}
   ⭐ ${item['rating']}/5.0 (${item['reviews_count']} reviews)
   ℹ️ ${_truncate(item['description'], 100)}''';

      case 'bookings':
        final pkg = item['packages'];
        return '''
📅 Booking #${item['id'].toString().substring(0, 8)}
   Status: ${item['status']}
   Package: ${pkg?['name'] ?? 'N/A'}
   Destination: ${pkg?['destination']}, ${pkg?['country']}
   Travel Date: ${item['travel_date']}
   Participants: ${item['participants']}
   Total: \$${item['total_amount']}
   Payment Status: ${item['payment_status']}''';

      case 'profile':
        return '''
👤 User Profile
   Name: ${item['full_name']}
   Email: ${item['email']}
   Phone: ${item['phone'] ?? 'Not set'}
   Role: ${item['role']}
   Member since: ${item['created_at']}''';

      default:
        return item.toString();
    }
  }

  static String _truncate(String? text, int maxLength) {
    if (text == null) return '';
    return text.length > maxLength 
        ? '${text.substring(0, maxLength)}...' 
        : text;
  }
}
