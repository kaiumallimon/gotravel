import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotravel/data/services/ai/database_schema.dart';

/// Dynamic Database Query Builder - AI can query any table intelligently
class DynamicDatabaseTool {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current authenticated user ID
  static String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// Execute a dynamic query with natural language understanding
  static Future<Map<String, dynamic>> intelligentQuery({
    required String table,
    String? searchText,
    Map<String, dynamic>? exactFilters,
    Map<String, dynamic>? rangeFilters, // {column: {'min': value, 'max': value}}
    String? orderBy,
    bool ascending = true,
    int limit = 10,
  }) async {
    try {
      final schema = DatabaseSchema.getTableSchema(table);
      if (schema == null) {
        return {
          'success': false,
          'error': 'Unknown table: $table. Available tables: ${DatabaseSchema.getAllTableNames().join(", ")}',
        };
      }

      // Check if user is authenticated for user-specific tables
      if (schema.userSpecific) {
        final userId = getCurrentUserId();
        if (userId == null) {
          return {
            'success': false,
            'error': 'Authentication required to access $table',
          };
        }
        // Auto-add user filter
        exactFilters = exactFilters ?? {};
        exactFilters[schema.userColumn!] = userId;
      }

      // Start building query
      dynamic query = _supabase.from(table).select();

      // Apply text search across searchable columns
      if (searchText != null && searchText.isNotEmpty && schema.searchableColumns.isNotEmpty) {
        final searchConditions = schema.searchableColumns
            .map((col) => '$col.ilike.%$searchText%')
            .join(',');
        query = query.or(searchConditions);
      }

      // Apply exact filters
      if (exactFilters != null) {
        exactFilters.forEach((column, value) {
          if (value is List) {
            query = query.inFilter(column, value);
          } else if (value is bool) {
            query = query.eq(column, value);
          } else {
            query = query.eq(column, value);
          }
        });
      }

      // Apply range filters (e.g., price between min and max)
      if (rangeFilters != null) {
        rangeFilters.forEach((column, range) {
          if (range is Map) {
            if (range.containsKey('min')) {
              query = query.gte(column, range['min']);
            }
            if (range.containsKey('max')) {
              query = query.lte(column, range['max']);
            }
          }
        });
      }

      // Apply ordering
      final orderColumn = orderBy ?? schema.defaultOrderBy;
      query = query.order(orderColumn, ascending: ascending);

      // Apply limit
      query = query.limit(limit);

      // Execute query
      final response = await query;

      return {
        'success': true,
        'data': response,
        'count': (response as List).length,
        'table': table,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Query failed: ${e.toString()}',
        'table': table,
      };
    }
  }

  /// Query with joins (for complex queries)
  static Future<Map<String, dynamic>> queryWithJoins({
    required String table,
    required String selectColumns, // e.g., "*, packages(name, destination)"
    Map<String, dynamic>? filters,
    String? orderBy,
    int limit = 10,
  }) async {
    try {
      final schema = DatabaseSchema.getTableSchema(table);
      if (schema == null) {
        return {
          'success': false,
          'error': 'Unknown table: $table',
        };
      }

      // Check authentication for user-specific tables
      if (schema.userSpecific) {
        final userId = getCurrentUserId();
        if (userId == null) {
          return {
            'success': false,
            'error': 'Authentication required',
          };
        }
        filters = filters ?? {};
        filters[schema.userColumn!] = userId;
      }

      dynamic query = _supabase.from(table).select(selectColumns);

      // Apply filters
      if (filters != null) {
        filters.forEach((column, value) {
          query = query.eq(column, value);
        });
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy);
      }

      query = query.limit(limit);

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

  /// Get aggregated statistics (count, sum, avg, etc.)
  static Future<Map<String, dynamic>> getStatistics({
    required String table,
    Map<String, dynamic>? filters,
  }) async {
    try {
      dynamic query = _supabase.from(table).select();

      if (filters != null) {
        filters.forEach((column, value) {
          query = query.eq(column, value);
        });
      }

      final response = await query;
      final count = response is List ? response.length : 0;

      return {
        'success': true,
        'count': count,
        'table': table,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Format query results for AI consumption
  static String formatResultsForAI(Map<String, dynamic> result, String context) {
    if (result['success'] == false) {
      return '❌ Error: ${result['error']}';
    }

    final table = result['table'] as String?;
    final data = result['data'];
    final count = result['count'] as int;

    if (data is List && data.isEmpty) {
      return '📭 No results found in ${table ?? "database"}.';
    }

    final buffer = StringBuffer();
    buffer.writeln('📊 Found $count result(s) from ${table ?? "query"}:\n');

    if (data is List) {
      for (var i = 0; i < data.length; i++) {
        final item = data[i];
        buffer.writeln(_formatItem(item, table ?? '', i + 1));
        if (i < data.length - 1) buffer.writeln();
      }
    } else {
      buffer.writeln(_formatItem(data, table ?? '', 1));
    }

    return buffer.toString();
  }

  static String _formatItem(Map<String, dynamic> item, String table, int index) {
    switch (table) {
      case 'packages':
        return '''$index. 📦 ${item['name']}
   📍 ${item['destination']}, ${item['country']}
   💰 \$${item['price']} (${item['currency'] ?? 'USD'})
   ⏱️ ${item['duration_days']} days
   ⭐ ${item['rating']}/5.0 (${item['reviews_count']} reviews)
   👥 Max ${item['max_participants']} participants
   📊 ${item['available_slots']} slots available''';

      case 'places':
        return '''$index. 🏞️ ${item['name']}
   📍 ${item['city']}, ${item['country']}
   🏷️ ${item['category']}
   💵 Entry: ${item['entry_fee'] != null ? '\$${item['entry_fee']}' : 'Free'}
   ⭐ ${item['rating']}/5.0''';

      case 'hotels':
        return '''$index. 🏨 ${item['name']}
   📍 ${item['city']}, ${item['country']}
   ⭐ ${item['star_rating']}-star | ${item['rating']}/5.0
   📞 ${item['contact_phone']}''';

      case 'rooms':
        return '''$index. 🛏️ ${item['room_type']}
   💰 \$${item['price_per_night']}/night
   👥 Capacity: ${item['capacity']}
   🛌 ${item['bed_type']}
   📊 ${item['available_rooms']}/${item['total_rooms']} available''';

      case 'bookings':
        return '''$index. 📅 Booking #${item['id'].toString().substring(0, 8)}
   Status: ${item['status']} | Payment: ${item['payment_status']}
   Travel Date: ${item['travel_date']}
   Participants: ${item['participants']}
   Total: \$${item['total_amount']}''';

      case 'payments':
        return '''$index. 💳 Payment #${item['transaction_id'] ?? item['id'].toString().substring(0, 8)}
   Amount: \$${item['amount']} ${item['currency']}
   Method: ${item['payment_method']}
   Status: ${item['status']}
   Date: ${item['payment_date']}''';

      case 'reviews':
        return '''$index. ⭐ Rating: ${item['rating']}/5
   ${item['comment']}
   Type: ${item['item_type']}
   Date: ${item['created_at']}''';

      case 'user_favorites':
        return '''$index. ❤️ Favorited ${item['item_type']}
   Added: ${item['created_at']}''';

      case 'users':
        return '''$index. 👤 ${item['full_name']}
   📧 ${item['email']}
   📱 ${item['phone'] ?? 'No phone'}
   Role: ${item['role']}''';

      case 'search_history':
        return '''$index. 🔍 "${item['search_query']}"
   Type: ${item['search_type']}
   Date: ${item['created_at']}''';

      case 'recommendations':
        return '''$index. 🌟 ${item['title']}
   ${item['description']}
   Type: ${item['item_type']}
   Priority: ${item['priority']}''';

      default:
        // Generic formatting for unknown tables
        final name = item['name'] ?? item['title'] ?? item['id'];
        return '''$index. $name
   ${item.entries.take(3).map((e) => '${e.key}: ${e.value}').join('\n   ')}''';
    }
  }

  /// Generate example queries for users
  static String getExampleQueries() {
    return '''Here are some example queries you can ask:

📦 PACKAGES:
• "Show me beach packages under \$500"
• "Find adventure tours in Nepal"
• "What are the highest rated packages?"

🏞️ PLACES:
• "Historical places in Dhaka"
• "Free attractions in Bangladesh"
• "Beach destinations with high ratings"

🏨 HOTELS:
• "5-star hotels in Dhaka"
• "Budget hotels in Cox's Bazar"
• "Hotels with highest ratings"

📅 YOUR DATA (requires login):
• "Show my bookings"
• "What packages did I favorite?"
• "My payment history"
• "My pending reservations"
• "Show my profile"

📊 STATISTICS:
• "How many packages are available?"
• "Count hotels in Dhaka"
• "Total bookings I made"''';
  }
}
