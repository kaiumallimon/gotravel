import 'dart:convert';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gotravel/data/services/ai/weather_tool.dart';
import 'package:gotravel/data/services/ai/ai_query_interpreter.dart';
import 'package:gotravel/data/services/ai/dynamic_database_tool.dart';

class AIService {
  final Gemini _gemini = Gemini.instance;
  final AIQueryInterpreter _queryInterpreter = AIQueryInterpreter();

  Future<String> chat(String userMessage, List<Map<String, String>> conversationHistory) async {
    try {
      final conversationContext = conversationHistory.map((msg) => "${msg['role']}: ${msg['content']}").join('\n');

      print('\n🤖 AI REASONING PROCESS:');
      print('📨 User: "$userMessage"');
      
      // Step 1: Let AI analyze and decide what it needs
      print('\n1️⃣ Analyzing user intent...');
      final reasoning = await _analyzeIntent(userMessage, conversationContext);
      print('💭 AI thinks: ${reasoning['thought']}');
      print('🎯 Needs: ${reasoning['needs']}');

      // Step 2: Fetch data only if AI decided it needs it
      print('\n2️⃣ Gathering required data...');
      final gatheredData = await _gatherData(reasoning, userMessage);
      print('📦 Data collected: ${gatheredData.keys.join(", ")}');

      // Step 3: Let AI formulate final response with gathered data
      print('\n3️⃣ Formulating response...');
      final finalAnswer = await _formulateResponse(
        userMessage: userMessage,
        reasoning: reasoning,
        gatheredData: gatheredData,
        context: conversationContext,
      );
      print('✅ Response ready\n');

      return finalAnswer;
    } catch (e) {
      print('❌ Error: $e');
      if (e.toString().contains('404') || e.toString().contains('API key')) {
        return _getAPIKeyError();
      }
      return 'I encountered an error: ${e.toString().split('\n').first}. Please try again.';
    }
  }

  /// Step 1: Let AI analyze the question and decide what data it needs
  Future<Map<String, dynamic>> _analyzeIntent(String userMessage, String context) async {
    try {
      final prompt = '''You are a travel assistant AI. Analyze this user question and decide what information you need to answer it.

Available data sources:
1. WEATHER: Current weather for any city (use for weather/temperature/climate questions)
2. DATABASE: Travel packages, hotels, places, bookings (use ONLY when user explicitly asks for specific data)
3. CONVERSATION: General travel advice, recommendations, explanations (use when you can answer without fetching data)

User question: "$userMessage"

Respond in JSON format:
{
  "thought": "Your reasoning about what the user wants",
  "needs": ["weather" | "database" | "conversation" | "multiple"],
  "specificNeeds": {
    "weather_location": "city name if weather needed",
    "database_query": "what to search for if database needed"
  }
}

IMPORTANT: 
- For weather questions, ONLY set needs=["weather"], NOT database!
- For general questions, use "conversation" 
- Only use "database" if user explicitly asks for packages/hotels/bookings
- Use "multiple" only if user asks compound questions like "weather AND cheapest package"''';

      final response = await _gemini.text(prompt);
      final jsonStr = _extractJSON(response?.output ?? '{}');
      final reasoning = _parseJSON(jsonStr);
      
      return reasoning;
    } catch (e) {
      print('⚠️ Intent analysis failed: $e');
      // Fallback to simple keyword detection
      return _fallbackIntentAnalysis(userMessage);
    }
  }

  /// Step 2: Gather data based on AI's decision
  Future<Map<String, dynamic>> _gatherData(Map<String, dynamic> reasoning, String userMessage) async {
    final needs = reasoning['needs'] as List<dynamic>? ?? [];
    final specificNeedsRaw = reasoning['specificNeeds'];
    final specificNeeds = specificNeedsRaw is Map ? Map<String, dynamic>.from(specificNeedsRaw) : <String, dynamic>{};
    final gatheredData = <String, dynamic>{};

    for (final need in needs) {
      switch (need) {
        case 'weather':
          final location = specificNeeds['weather_location']?.toString() ?? _extractLocation(userMessage);
          if (location.isNotEmpty) {
            print('  🌤️ Fetching weather for: $location');
            final weatherData = await WeatherTool.getCurrentWeather(location);
            if (weatherData['success'] == true) {
              gatheredData['weather'] = WeatherTool.formatWeatherForAI(weatherData);
            } else {
              gatheredData['weather'] = 'Weather data unavailable: ${weatherData['error']}';
            }
          }
          break;

        case 'database':
          final query = specificNeeds['database_query']?.toString() ?? userMessage;
          print('  🗄️ Querying database: $query');
          final dbResult = await _callDatabaseTool(query);
          if (dbResult.success && dbResult.data != null) {
            gatheredData['database'] = dbResult.data;
          } else {
            gatheredData['database'] = 'No data found: ${dbResult.message}';
          }
          break;

        case 'conversation':
          // No data needed - AI will use general knowledge
          break;
      }
    }

    return gatheredData;
  }

  /// Step 3: Let AI formulate final response with gathered data
  Future<String> _formulateResponse({
    required String userMessage,
    required Map<String, dynamic> reasoning,
    required Map<String, dynamic> gatheredData,
    required String context,
  }) async {
    try {
      final prompt = '''You are a friendly travel assistant. Formulate a natural response to the user.

User question: "$userMessage"

Your reasoning: ${reasoning['thought']}

Available data:
${gatheredData.entries.map((e) => '${e.key.toUpperCase()}:\n${e.value}').join('\n\n')}

Provide a helpful, conversational response. If data was fetched, incorporate it naturally. If no data was needed, provide helpful travel advice.''';

      final response = await _gemini.text(prompt);
      return response?.output ?? _getFallbackResponse();
    } catch (e) {
      print('⚠️ Response formulation failed: $e');
      // Return gathered data directly if AI fails
      if (gatheredData.isNotEmpty) {
        return gatheredData.values.first.toString();
      }
      return _getFallbackResponse();
    }
  }

  Map<String, dynamic> _fallbackIntentAnalysis(String message) {
    final lower = message.toLowerCase();
    
    if (lower.contains('weather') || lower.contains('temperature') || lower.contains('climate')) {
      return {
        'thought': 'User is asking about weather',
        'needs': ['weather'],
        'specificNeeds': {'weather_location': _extractLocation(message)},
      };
    }
    
    if ((lower.contains('show') || lower.contains('find') || lower.contains('cheapest') || lower.contains('best')) &&
        (lower.contains('package') || lower.contains('hotel') || lower.contains('place'))) {
      return {
        'thought': 'User wants to search travel data',
        'needs': ['database'],
        'specificNeeds': {'database_query': message},
      };
    }
    
    return {
      'thought': 'General travel question',
      'needs': ['conversation'],
      'specificNeeds': {},
    };
  }

  /// Helper: Extract JSON from AI response (handles markdown code blocks)
  String _extractJSON(String text) {
    final jsonMatch = RegExp(r'```(?:json)?\s*(\{.*?\})\s*```', dotAll: true).firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(1)!;
    }
    final directMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);
    return directMatch?.group(0) ?? '{}';
  }

  /// Helper: Parse JSON safely using dart:convert
  Map<String, dynamic> _parseJSON(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return {};
    } catch (e) {
      print('⚠️ JSON parse error: $e');
      print('⚠️ Raw JSON: $jsonStr');
      return {};
    }
  }

  Future<ToolResult> _callDatabaseTool(String userMessage) async {
    try {
      print('[DB] Interpreting query: "$userMessage"');
      final queryIntent = await _queryInterpreter.interpretQuery(userMessage);
      print('[DB] Query intent: table=${queryIntent.table}, filters=${queryIntent.exactFilters}, ranges=${queryIntent.rangeFilters}');
      
      final result = await _queryInterpreter.executeQuery(queryIntent);
      print('[DB] Query result: success=${result['success']}, count=${result['count']}, error=${result['error']}');
      
      if (result['success'] == true) {
        final formattedData = DynamicDatabaseTool.formatResultsForAI(result, queryIntent.table);
        print('[DB] Formatted ${result['count']} results');
        return ToolResult(success: true, data: formattedData, message: 'Query executed', metadata: {'table': queryIntent.table, 'count': result['count']});
      } else {
        return ToolResult(success: false, data: null, message: result['error'] ?? 'Query failed');
      }
    } catch (e) {
      print('[DB] Error: ${e.toString()}');
      return ToolResult(success: false, data: null, message: 'Database tool error: ${e.toString()}');
    }
  }

  String _extractLocation(String message) {
    final words = message.split(' ');
    final prep = ['in', 'at', 'near', 'around', 'to'];
    
    for (int i = 0; i < words.length - 1; i++) {
      if (prep.contains(words[i].toLowerCase())) {
        // Extract location - can be multiple words (e.g., "Cox's Bazar")
        // Take remaining words after preposition, stopping at punctuation or end
        List<String> locationWords = [];
        for (int j = i + 1; j < words.length; j++) {
          final word = words[j].replaceAll(RegExp(r'[?!.,]$'), ''); // Remove trailing punctuation
          if (word.isNotEmpty) {
            locationWords.add(word);
            // Stop at next preposition or question word
            if (j < words.length - 1 && 
                (prep.contains(words[j + 1].toLowerCase()) || 
                 ['what', 'how', 'when', 'where', 'why'].contains(words[j + 1].toLowerCase()))) {
              break;
            }
          }
        }
        return locationWords.join(' ');
      }
    }
    
    return '';
  }

  String _getAPIKeyError() {
    return 'API Configuration Error\n\nThe Gemini API key is not configured properly. Please add it to your .env file.\n\nI can still help with weather information and finding tour packages.';
  }

  String _getFallbackResponse() {
    return 'Hello! I am your AI Travel Assistant.\n\nI can help with:\n- Weather information\n- Tour packages\n- Places to visit\n- Hotels\n- Your bookings (when logged in)\n\nWhat would you like to know?';
  }
}

enum IntentType { weather, database, userData, conversation }

class UserIntent {
  final IntentType type;
  final Map<String, dynamic> parameters;
  UserIntent({required this.type, required this.parameters});
  @override
  String toString() => 'UserIntent(type: $type, parameters: $parameters)';
}

class ToolResult {
  final bool success;
  final String? data;
  final String message;
  final Map<String, dynamic>? metadata;
  ToolResult({required this.success, required this.data, required this.message, this.metadata});
  @override
  String toString() => 'ToolResult(success: $success, message: $message, hasData: ${data != null})';
}