import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gotravel/data/services/ai/database_schema.dart';
import 'package:gotravel/data/services/ai/dynamic_database_tool.dart';
import 'dart:convert';

/// AI Query Interpreter - Uses Gemini to understand user intent and generate database queries
class AIQueryInterpreter {
  final Gemini _gemini = Gemini.instance;

  /// Interpret user query and decide what database operations to perform
  Future<DatabaseQueryIntent> interpretQuery(String userQuery) async {
    final schemaInfo = DatabaseSchema.getSchemaForAI();
    
    final prompt = '''You are a database query interpreter. Analyze the user's natural language query and determine:
1. Which table(s) to query
2. What filters to apply
3. How to order results
4. What the user is looking for

DATABASE SCHEMA:
$schemaInfo

USER QUERY: "$userQuery"

Respond with a JSON object with this structure:
{
  "table": "table_name",
  "intent": "search|list|count|my_data",
  "searchText": "optional search keywords",
  "exactFilters": {"column": "value"},
  "rangeFilters": {"price": {"min": 100, "max": 500}},
  "orderBy": "column_name",
  "ascending": true,
  "limit": 10,
  "needsAuth": false
}

Examples:
- "Show beach packages under \$500" → {"table": "packages", "intent": "search", "exactFilters": {"category": "Beach"}, "rangeFilters": {"price": {"max": 500}}, "orderBy": "price", "limit": 10}
- "My bookings" → {"table": "bookings", "intent": "my_data", "needsAuth": true, "orderBy": "created_at", "ascending": false}
- "Hotels in Dhaka" → {"table": "hotels", "intent": "search", "exactFilters": {"city": "Dhaka"}, "orderBy": "rating", "ascending": false}

IMPORTANT:
- For "my/mine" queries, set needsAuth=true and use appropriate user-specific table
- Use searchText for fuzzy matching across name/description fields
- Use exactFilters for precise matches (status, category, city, etc.)
- Use rangeFilters for numeric comparisons (price, rating, duration)
- Choose appropriate orderBy and limit

Respond ONLY with valid JSON, no explanation.''';

    try {
      final response = await _gemini.text(prompt);
      final jsonStr = _extractJSON(response?.output ?? '{}');
      final json = jsonDecode(jsonStr);
      
      return DatabaseQueryIntent.fromJson(json);
    } catch (e) {
      // Fallback to simple pattern matching
      return _fallbackInterpretation(userQuery);
    }
  }

  /// Extract JSON from response (handles markdown code blocks)
  String _extractJSON(String text) {
    // Remove markdown code blocks
    final cleanText = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    
    // Find JSON object
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanText);
    return jsonMatch?.group(0) ?? '{}';
  }

  /// Fallback interpretation using pattern matching
  DatabaseQueryIntent _fallbackInterpretation(String userQuery) {
    final lowerQuery = userQuery.toLowerCase();
    
    // Detect user-specific queries
    if (lowerQuery.contains('my ') || lowerQuery.contains('mine')) {
      if (lowerQuery.contains('booking') || lowerQuery.contains('reservation')) {
        return DatabaseQueryIntent(
          table: 'bookings',
          intent: 'my_data',
          needsAuth: true,
          orderBy: 'created_at',
          ascending: false,
        );
      } else if (lowerQuery.contains('favorite') || lowerQuery.contains('saved')) {
        return DatabaseQueryIntent(
          table: 'user_favorites',
          intent: 'my_data',
          needsAuth: true,
          orderBy: 'created_at',
          ascending: false,
        );
      } else if (lowerQuery.contains('payment') || lowerQuery.contains('transaction')) {
        return DatabaseQueryIntent(
          table: 'payments',
          intent: 'my_data',
          needsAuth: true,
          orderBy: 'payment_date',
          ascending: false,
        );
      } else if (lowerQuery.contains('profile') || lowerQuery.contains('account')) {
        return DatabaseQueryIntent(
          table: 'users',
          intent: 'my_data',
          needsAuth: true,
          limit: 1,
        );
      }
    }

    // Detect package queries
    if (lowerQuery.contains('package') || lowerQuery.contains('tour') || lowerQuery.contains('trip')) {
      final filters = <String, dynamic>{};
      final rangeFilters = <String, dynamic>{};
      
      if (lowerQuery.contains('beach')) filters['category'] = 'Beach';
      else if (lowerQuery.contains('mountain')) filters['category'] = 'Mountain';
      else if (lowerQuery.contains('cultural')) filters['category'] = 'Cultural';
      else if (lowerQuery.contains('adventure')) filters['category'] = 'Adventure';
      
      // Extract price
      final priceMatch = RegExp(r'\$(\d+)').firstMatch(userQuery);
      if (priceMatch != null) {
        final price = double.tryParse(priceMatch.group(1)!);
        rangeFilters['price'] = {'max': price};
      } else if (lowerQuery.contains('cheap') || lowerQuery.contains('budget')) {
        rangeFilters['price'] = {'max': 500};
      }
      
      return DatabaseQueryIntent(
        table: 'packages',
        intent: 'search',
        exactFilters: filters.isNotEmpty ? filters : null,
        rangeFilters: rangeFilters.isNotEmpty ? rangeFilters : null,
        orderBy: 'price',
        ascending: true,
      );
    }

    // Detect place queries
    if (lowerQuery.contains('place') || lowerQuery.contains('attraction') || lowerQuery.contains('visit')) {
      final filters = <String, dynamic>{};
      
      if (lowerQuery.contains('historical')) filters['category'] = 'Historical';
      else if (lowerQuery.contains('beach')) filters['category'] = 'Beach';
      else if (lowerQuery.contains('park')) filters['category'] = 'Park';
      else if (lowerQuery.contains('museum')) filters['category'] = 'Museum';
      
      return DatabaseQueryIntent(
        table: 'places',
        intent: 'search',
        exactFilters: filters.isNotEmpty ? filters : null,
        orderBy: 'rating',
        ascending: false,
      );
    }

    // Detect hotel queries
    if (lowerQuery.contains('hotel') || lowerQuery.contains('accommodation') || lowerQuery.contains('stay')) {
      final filters = <String, dynamic>{};
      final rangeFilters = <String, dynamic>{};
      
      if (lowerQuery.contains('5 star') || lowerQuery.contains('luxury')) {
        rangeFilters['rating'] = {'min': 4.5};
      } else if (lowerQuery.contains('4 star')) {
        rangeFilters['star_rating'] = {'min': 4};
      }
      
      return DatabaseQueryIntent(
        table: 'hotels',
        intent: 'search',
        exactFilters: filters.isNotEmpty ? filters : null,
        rangeFilters: rangeFilters.isNotEmpty ? rangeFilters : null,
        orderBy: 'rating',
        ascending: false,
      );
    }

    // Default: list packages
    return DatabaseQueryIntent(
      table: 'packages',
      intent: 'list',
      orderBy: 'rating',
      ascending: false,
    );
  }

  /// Execute the interpreted query
  Future<Map<String, dynamic>> executeQuery(DatabaseQueryIntent intent) async {
    // Check authentication requirement
    if (intent.needsAuth && DynamicDatabaseTool.getCurrentUserId() == null) {
      return {
        'success': false,
        'error': 'Authentication required for this query',
      };
    }

    return await DynamicDatabaseTool.intelligentQuery(
      table: intent.table,
      searchText: intent.searchText,
      exactFilters: intent.exactFilters,
      rangeFilters: intent.rangeFilters,
      orderBy: intent.orderBy,
      ascending: intent.ascending,
      limit: intent.limit,
    );
  }
}

/// Represents the AI's interpretation of user query
class DatabaseQueryIntent {
  final String table;
  final String intent; // search, list, count, my_data
  final String? searchText;
  final Map<String, dynamic>? exactFilters;
  final Map<String, dynamic>? rangeFilters;
  final String? orderBy;
  final bool ascending;
  final int limit;
  final bool needsAuth;

  DatabaseQueryIntent({
    required this.table,
    required this.intent,
    this.searchText,
    this.exactFilters,
    this.rangeFilters,
    this.orderBy,
    this.ascending = true,
    this.limit = 10,
    this.needsAuth = false,
  });

  factory DatabaseQueryIntent.fromJson(Map<String, dynamic> json) {
    return DatabaseQueryIntent(
      table: json['table'] as String,
      intent: json['intent'] as String? ?? 'search',
      searchText: json['searchText'] as String?,
      exactFilters: json['exactFilters'] as Map<String, dynamic>?,
      rangeFilters: json['rangeFilters'] as Map<String, dynamic>?,
      orderBy: json['orderBy'] as String?,
      ascending: json['ascending'] as bool? ?? true,
      limit: json['limit'] as int? ?? 10,
      needsAuth: json['needsAuth'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table': table,
      'intent': intent,
      'searchText': searchText,
      'exactFilters': exactFilters,
      'rangeFilters': rangeFilters,
      'orderBy': orderBy,
      'ascending': ascending,
      'limit': limit,
      'needsAuth': needsAuth,
    };
  }

  @override
  String toString() {
    return 'Query Intent: $intent on table "$table"\n'
        'Filters: ${exactFilters ?? {}}\n'
        'Ranges: ${rangeFilters ?? {}}\n'
        'Order: ${orderBy ?? "default"} (${ascending ? "ASC" : "DESC"})\n'
        'Limit: $limit\n'
        'Auth Required: $needsAuth';
  }
}
