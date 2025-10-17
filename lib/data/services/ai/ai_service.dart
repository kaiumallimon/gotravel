import 'dart:convert';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gotravel/data/services/ai/travel_tools.dart';

/// Simple Tool-Based AI Service
/// AI selects appropriate tool, calls it, verifies results, then responds
class AIService {
  final Gemini _gemini = Gemini.instance;

  Future<String> chat(String userMessage, List<Map<String, String>> conversationHistory) async {
    try {
      print('\n🤖 AI ASSISTANT:');
      print('📨 User Query: "$userMessage"');

      // Step 1: AI selects the appropriate tool
      print('\n1️⃣ Selecting tool...');
      final toolSelection = await _selectTool(userMessage);
      print('🔧 Selected: ${toolSelection['tool']}');

      // Step 2: Call the selected tool
      print('\n2️⃣ Executing tool...');
      final toolResult = await _callTool(toolSelection);
      print('📦 Result: ${toolResult['success'] ? "Success (${toolResult['count'] ?? 0} items)" : "Failed"}');

      // Step 3: AI verifies results match user intent
      print('\n3️⃣ Verifying & formulating response...');
      final finalAnswer = await _verifyAndRespond(
        userMessage: userMessage,
        toolName: toolSelection['tool'] ?? 'unknown',
        toolResult: toolResult,
        conversationHistory: conversationHistory,
      );
      print('✅ Response ready\n');

      return finalAnswer;
    } catch (e) {
      print('❌ Error: $e\n');
      return _handleError(e);
    }
  }

  /// Step 1: AI analyzes query and selects appropriate tool
  Future<Map<String, dynamic>> _selectTool(String userMessage) async {
    try {
      final prompt = '''You are a travel assistant AI. Analyze the user's query and select the most appropriate tool.

User Query: "$userMessage"

${TravelTools.getAvailableToolsList()}

Respond ONLY with JSON in this format:
{
  "tool": "tool_name",
  "parameters": {"param_name": "value"},
  "reasoning": "why this tool fits the query"
}

Examples:
- "show cheapest packages" → {"tool": "cheapest_packages", "parameters": {}, "reasoning": "User wants affordable options"}
- "weather in Paris" → {"tool": "weather", "parameters": {"location": "Paris"}, "reasoning": "User wants weather information"}
- "my bookings" → {"tool": "my_bookings", "parameters": {}, "reasoning": "User wants their booking history"}
- "beach vacation" → {"tool": "beach_packages", "parameters": {}, "reasoning": "User interested in beach packages"}
- "beginner destinations" → {"tool": "beginner_packages", "parameters": {}, "reasoning": "User wants easy/beginner-friendly trips"}
- "Cox's Bazar packages" → {"tool": "packages_by_destination", "parameters": {"destination": "Cox's Bazar"}, "reasoning": "User wants packages for specific destination"}

IMPORTANT: Return ONLY the JSON, nothing else!''';

      final response = await _gemini.text(prompt);
      final jsonStr = _extractJSON(response?.output ?? '{}');
      return jsonDecode(jsonStr);
    } catch (e) {
      print('⚠️ Tool selection failed: $e');
      return _fallbackToolSelection(userMessage);
    }
  }

  /// Step 2: Execute the selected tool
  Future<Map<String, dynamic>> _callTool(Map<String, dynamic> toolSelection) async {
    final toolName = toolSelection['tool'] as String?;
    final parameters = toolSelection['parameters'] as Map<String, dynamic>? ?? {};

    switch (toolName) {
      // Package tools
      case 'cheapest_packages':
        return await TravelTools.getCheapestPackages();
      case 'premium_packages':
        return await TravelTools.getPremiumPackages();
      case 'top_rated_packages':
        return await TravelTools.getTopRatedPackages();
      case 'beach_packages':
        return await TravelTools.getBeachPackages();
      case 'mountain_packages':
        return await TravelTools.getMountainPackages();
      case 'wildlife_packages':
        return await TravelTools.getWildlifePackages();
      case 'cultural_packages':
        return await TravelTools.getCulturalPackages();
      case 'beginner_packages':
        return await TravelTools.getBeginnerPackages();
      case 'weekend_packages':
        return await TravelTools.getWeekendPackages();
      case 'long_vacation_packages':
        return await TravelTools.getLongVacationPackages();
      case 'budget_packages':
        return await TravelTools.getBudgetPackages();
      case 'packages_by_destination':
        final destination = parameters['destination']?.toString() ?? '';
        return await TravelTools.getPackagesByDestination(destination);

      // User-specific tools
      case 'my_favorites':
        return await TravelTools.getMyFavoritePackages();
      case 'my_bookings':
        return await TravelTools.getMyBookings();
      case 'upcoming_bookings':
        return await TravelTools.getMyUpcomingBookings();
      case 'search_history':
        return await TravelTools.getMySearchHistory();

      // Place tools
      case 'popular_places':
        return await TravelTools.getPopularPlaces();
      case 'places_by_category':
        final category = parameters['category']?.toString() ?? '';
        return await TravelTools.getPlacesByCategory(category);

      // Hotel tools
      case 'top_hotels':
        return await TravelTools.getTopRatedHotels();
      case 'hotels_by_city':
        final city = parameters['city']?.toString() ?? '';
        return await TravelTools.getHotelsByCity(city);

      // Weather tool
      case 'weather':
        final location = parameters['location']?.toString() ?? '';
        return await TravelTools.getWeather(location);

      // Recommendations
      case 'recommendations':
        return await TravelTools.getRecommendationsForUser();

      // Conversation (no tool needed)
      case 'conversation':
        return {'success': true, 'tool': 'conversation', 'data': null};

      default:
        return {
          'success': false,
          'tool': toolName ?? 'unknown',
          'error': 'Unknown tool: $toolName'
        };
    }
  }

  /// Step 3: AI verifies results and formulates natural response
  Future<String> _verifyAndRespond({
    required String userMessage,
    required String toolName,
    required Map<String, dynamic> toolResult,
    required List<Map<String, String>> conversationHistory,
  }) async {
    // Handle tool failures
    if (toolResult['success'] == false) {
      return _handleToolFailure(toolName, toolResult['error']?.toString() ?? 'Unknown error');
    }

    // Handle empty results
    final data = toolResult['data'];
    
    if (data is List && data.isEmpty) {
      return _handleEmptyResults(toolName, userMessage);
    }

    // Special handling for conversational queries (no data)
    if (toolName == 'conversation' || data == null) {
      return await _conversationalResponse(userMessage, conversationHistory);
    }

    // Format data for AI
    final formattedData = _formatDataForAI(toolResult);

    // Let AI verify and create natural response
    try {
      final prompt = '''You are a friendly travel assistant. Verify the results match the user's query and provide a helpful response.

USER QUERY: "$userMessage"

TOOL USED: $toolName

DATA RETRIEVED:
$formattedData

TASK:
1. Verify the data actually answers the user's question
2. If data is relevant, provide a natural, friendly response incorporating the information
3. If data doesn't match, politely explain and suggest what the user might be looking for
4. Keep response conversational and helpful

Provide ONLY the response text, no JSON or metadata.''';

      final response = await _gemini.text(prompt);
      return response?.output ?? formattedData;
    } catch (e) {
      print('⚠️ AI response generation failed: $e');
      return formattedData; // Fallback to formatted data
    }
  }

  /// Format tool results for AI consumption
  String _formatDataForAI(Map<String, dynamic> toolResult) {
    final toolName = toolResult['tool'] as String;
    final data = toolResult['data'];
    final count = toolResult['count'] ?? 0;

    if (data == null) return 'No data available';
    if (data is! List) return data.toString();
    if (data.isEmpty) return 'No results found';

    final buffer = StringBuffer();
    buffer.writeln('Found $count result(s):\n');

    for (int i = 0; i < data.length && i < 10; i++) {
      final item = data[i] as Map<String, dynamic>;
      buffer.writeln('${i + 1}. ${_formatItem(item, toolName)}');
      if (i < data.length - 1) buffer.writeln();
    }

    return buffer.toString();
  }

  /// Format individual items based on type
  String _formatItem(Map<String, dynamic> item, String toolName) {
    if (toolName.contains('package')) {
      return '''📦 ${item['name']}
   📍 ${item['destination']}, ${item['country']}
   💰 \$${item['price']} ${item['currency'] ?? 'USD'}
   ⏱️ ${item['duration_days']} days
   ⭐ ${item['rating']}/5.0 (${item['reviews_count']} reviews)
   👥 ${item['available_slots']} slots available''';
    } else if (toolName.contains('place')) {
      return '''🏞️ ${item['name']}
   📍 ${item['location']}
   ⭐ ${item['rating']}/5.0
   📝 ${item['description']?.toString().substring(0, 100) ?? ''}...''';
    } else if (toolName.contains('hotel')) {
      return '''🏨 ${item['name']}
   📍 ${item['city']}, ${item['country']}
   ⭐ ${item['rating']}/5.0 (${item['reviews_count']} reviews)
   📞 ${item['phone']}''';
    } else if (toolName.contains('booking')) {
      return '''🎫 ${item['packages']?['name'] ?? 'Booking'}
   📅 ${item['booking_date']}
   👥 ${item['travelers_count']} travelers
   💰 \$${item['total_amount']}
   📊 Status: ${item['status']}''';
    } else if (toolName == 'weather') {
      return '''🌤️ ${item['location']}
   🌡️ ${item['temperature']}°C (Feels like ${item['feels_like']}°C)
   📝 ${item['description']}
   💧 Humidity: ${item['humidity']}%
   💨 Wind: ${item['wind_speed']} m/s''';
    }

    return item.toString();
  }

  /// Fallback tool selection using keyword matching
  Map<String, dynamic> _fallbackToolSelection(String query) {
    final lower = query.toLowerCase();

    // Weather queries
    if (lower.contains('weather') || lower.contains('temperature') || lower.contains('forecast')) {
      final location = _extractLocation(query);
      return {'tool': 'weather', 'parameters': {'location': location}};
    }

    // User-specific
    if (lower.contains('my favorite') || lower.contains('my favourite')) {
      return {'tool': 'my_favorites', 'parameters': {}};
    }
    if (lower.contains('my booking')) {
      return {'tool': 'my_bookings', 'parameters': {}};
    }
    if (lower.contains('upcoming')) {
      return {'tool': 'upcoming_bookings', 'parameters': {}};
    }

    // Package queries by price
    if (lower.contains('cheap') || lower.contains('affordable') || lower.contains('budget')) {
      return {'tool': 'cheapest_packages', 'parameters': {}};
    }
    if (lower.contains('premium') || lower.contains('luxury') || lower.contains('expensive')) {
      return {'tool': 'premium_packages', 'parameters': {}};
    }

    // Package queries by category
    if (lower.contains('beach') || lower.contains('sea') || lower.contains('coast')) {
      return {'tool': 'beach_packages', 'parameters': {}};
    }
    if (lower.contains('mountain') || lower.contains('hill') || lower.contains('trek')) {
      return {'tool': 'mountain_packages', 'parameters': {}};
    }
    if (lower.contains('wildlife') || lower.contains('nature') || lower.contains('forest')) {
      return {'tool': 'wildlife_packages', 'parameters': {}};
    }
    if (lower.contains('cultural') || lower.contains('heritage') || lower.contains('historical')) {
      return {'tool': 'cultural_packages', 'parameters': {}};
    }

    // Package queries by difficulty/duration
    if (lower.contains('beginner') || lower.contains('easy') || lower.contains('simple')) {
      return {'tool': 'beginner_packages', 'parameters': {}};
    }
    if (lower.contains('weekend') || lower.contains('short')) {
      return {'tool': 'weekend_packages', 'parameters': {}};
    }
    if (lower.contains('long') || lower.contains('vacation') || lower.contains('extended')) {
      return {'tool': 'long_vacation_packages', 'parameters': {}};
    }

    // Top-rated
    if (lower.contains('best') || lower.contains('top') || lower.contains('rated')) {
      return {'tool': 'top_rated_packages', 'parameters': {}};
    }

    // Destination search
    if (lower.contains('package') || lower.contains('tour')) {
      final destination = _extractDestination(query);
      if (destination.isNotEmpty) {
        return {'tool': 'packages_by_destination', 'parameters': {'destination': destination}};
      }
      return {'tool': 'top_rated_packages', 'parameters': {}};
    }

    // Places
    if (lower.contains('place') || lower.contains('visit') || lower.contains('attraction')) {
      return {'tool': 'popular_places', 'parameters': {}};
    }

    // Hotels
    if (lower.contains('hotel') || lower.contains('accommodation')) {
      final city = _extractLocation(query);
      if (city.isNotEmpty) {
        return {'tool': 'hotels_by_city', 'parameters': {'city': city}};
      }
      return {'tool': 'top_hotels', 'parameters': {}};
    }

    // Default to conversation
    return {'tool': 'conversation', 'parameters': {}};
  }

  /// Extract location from query
  String _extractLocation(String message) {
    final words = message.split(' ');
    final prep = ['in', 'at', 'near', 'around', 'to', 'for'];
    
    for (int i = 0; i < words.length - 1; i++) {
      if (prep.contains(words[i].toLowerCase())) {
        List<String> locationWords = [];
        for (int j = i + 1; j < words.length; j++) {
          final word = words[j].replaceAll(RegExp(r'[?!.,]$'), '');
          if (word.isNotEmpty) {
            locationWords.add(word);
            if (j < words.length - 1 && (prep.contains(words[j + 1].toLowerCase()) || ['what', 'how', 'when', 'where'].contains(words[j + 1].toLowerCase()))) {
              break;
            }
          }
        }
        return locationWords.join(' ');
      }
    }
    return '';
  }

  /// Extract destination name from query
  String _extractDestination(String query) {
    // Try to extract from common patterns
    final patterns = [
      RegExp(r'(?:packages?|tours?)\s+(?:to|in|for|at)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)', caseSensitive: false),
      RegExp(r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)\s+(?:packages?|tours?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(query);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    return '';
  }

  /// Extract JSON from AI response
  String _extractJSON(String text) {
    final jsonMatch = RegExp(r'```(?:json)?\s*(\{.*?\})\s*```', dotAll: true).firstMatch(text);
    if (jsonMatch != null) return jsonMatch.group(1)!;
    
    final directMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);
    return directMatch?.group(0) ?? '{}';
  }

  /// Handle tool execution failures
  String _handleToolFailure(String toolName, String error) {
    if (error.contains('login') || error.contains('auth')) {
      return '🔐 Please login to access this feature.\n\nYou need to be signed in to view your personal data like bookings and favorites.';
    }

    return '❌ Sorry, I couldn\'t retrieve that information right now.\n\nError: $error\n\nPlease try again or rephrase your question.';
  }

  /// Handle empty results
  String _handleEmptyResults(String toolName, String query) {
    if (toolName.contains('my_')) {
      return '📭 You don\'t have any items in this category yet.\n\nStart exploring our packages and create your first booking!';
    }

    return '📭 No results found for "$query".\n\nTry:\n• Using different keywords\n• Being more specific\n• Asking for general categories like "beach packages" or "budget tours"';
  }

  /// Generate conversational response
  Future<String> _conversationalResponse(String userMessage, List<Map<String, String>> history) async {
    try {
      final context = history.map((m) => '${m['role']}: ${m['content']}').join('\n');
      final prompt = '''You are a friendly AI Travel Assistant for GoTravel app.

Conversation History:
$context

User: $userMessage

Provide a helpful, conversational response. You can help with:
- Tour packages (beach, mountain, wildlife, cultural, etc.)
- Weather information for any location
- Hotels and places to visit
- User's bookings and favorites (when logged in)
- Travel recommendations and advice

Keep your response friendly, concise, and helpful.''';

      final response = await _gemini.text(prompt);
      return response?.output ?? _getDefaultResponse();
    } catch (e) {
      return _getDefaultResponse();
    }
  }

  /// Handle errors
  String _handleError(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('404') || errorStr.contains('API key')) {
      return '⚠️ AI service configuration error.\n\nSome features may be limited. You can still:\n• Search for packages\n• Check weather\n• View bookings';
    }
    return '❌ An error occurred. Please try again.';
  }

  /// Default response
  String _getDefaultResponse() {
    return '''👋 Hello! I'm your AI Travel Assistant.

I can help you with:
• 🏖️ Finding tour packages (beach, mountain, cultural, etc.)
• 🌤️ Checking weather anywhere in the world
• 🏨 Finding hotels and places to visit
• 📋 Viewing your bookings and favorites
• 💡 Getting travel recommendations

What would you like to know?''';
  }
}
