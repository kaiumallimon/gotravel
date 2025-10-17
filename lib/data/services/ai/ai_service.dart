import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gotravel/data/services/ai/weather_tool.dart';
import 'package:gotravel/data/services/ai/ai_query_interpreter.dart';
import 'package:gotravel/data/services/ai/dynamic_database_tool.dart';
import 'package:gotravel/data/services/ai/database_schema.dart';

class AIService {
  final Gemini _gemini = Gemini.instance;
  final AIQueryInterpreter _queryInterpreter = AIQueryInterpreter();

  Future<String> chat(String userMessage, List<Map<String, String>> conversationHistory) async {
    try {
      final conversationContext = conversationHistory.map((msg) => "${msg['role']}: ${msg['content']}").join('\n');

      print('Step 1: Classifying intent...');
      final intent = await _classifyIntent(userMessage, conversationContext);
      print('Intent: ${intent.type}');

      print('Step 2: Calling tools...');
      final toolResult = await _callTools(intent, userMessage);
      print('Tools executed');

      print('Step 3: Formatting answer...');
      final finalAnswer = await _formatFinalAnswer(
        userMessage: userMessage,
        intent: intent,
        toolResult: toolResult,
        context: conversationContext,
      );
      print('Answer ready');

      return finalAnswer;
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('404') || e.toString().contains('API key')) {
        return _getAPIKeyError();
      }
      return 'I encountered an error: ${e.toString().split('\n').first}. Please try again.';
    }
  }

  Future<UserIntent> _classifyIntent(String userMessage, String context) async {
    final lowerMessage = userMessage.toLowerCase();

    if (_isWeatherQuery(lowerMessage)) {
      return UserIntent(
        type: IntentType.weather,
        parameters: {'location': _extractLocation(userMessage)},
      );
    }

    if (_isUserDataQuery(lowerMessage)) {
      return UserIntent(
        type: IntentType.userData,
        parameters: {'query': userMessage},
      );
    }

    if (_isDatabaseQuery(lowerMessage)) {
      return UserIntent(
        type: IntentType.database,
        parameters: {'query': userMessage},
      );
    }

    return UserIntent(
      type: IntentType.conversation,
      parameters: {'query': userMessage},
    );
  }

  bool _isWeatherQuery(String message) {
    return message.contains('weather') || message.contains('temperature') || message.contains('forecast') || message.contains('climate');
  }

  bool _isUserDataQuery(String message) {
    return (message.contains('my ') || message.contains('mine')) && (message.contains('booking') || message.contains('favorite') || message.contains('profile') || message.contains('payment'));
  }

  bool _isDatabaseQuery(String message) {
    return message.contains('show') || message.contains('find') || message.contains('search') || message.contains('get') || message.contains('list') || message.contains('package') || message.contains('hotel') || message.contains('place') || message.contains('cheapest') || message.contains('best') || message.contains('top');
  }

  Future<ToolResult> _callTools(UserIntent intent, String userMessage) async {
    switch (intent.type) {
      case IntentType.weather:
        return await _callWeatherTool(intent.parameters['location'] ?? '');
      case IntentType.userData:
      case IntentType.database:
        return await _callDatabaseTool(userMessage);
      case IntentType.conversation:
        return ToolResult(success: true, data: null, message: 'No tool needed');
    }
  }

  Future<ToolResult> _callWeatherTool(String location) async {
    try {
      if (location.isEmpty) {
        return ToolResult(success: false, data: null, message: 'Location not specified');
      }
      final weatherData = await WeatherTool.getCurrentWeather(location);
      final formattedWeather = WeatherTool.formatWeatherForAI(weatherData);
      return ToolResult(success: true, data: formattedWeather, message: 'Weather retrieved');
    } catch (e) {
      return ToolResult(success: false, data: null, message: 'Failed to get weather: ${e.toString()}');
    }
  }

  Future<ToolResult> _callDatabaseTool(String userMessage) async {
    try {
      final queryIntent = await _queryInterpreter.interpretQuery(userMessage);
      final result = await _queryInterpreter.executeQuery(queryIntent);
      if (result['success'] == true) {
        final formattedData = DynamicDatabaseTool.formatResultsForAI(result, queryIntent.table);
        return ToolResult(success: true, data: formattedData, message: 'Query executed', metadata: {'table': queryIntent.table, 'count': result['count']});
      } else {
        return ToolResult(success: false, data: null, message: result['error'] ?? 'Query failed');
      }
    } catch (e) {
      return ToolResult(success: false, data: null, message: 'Database tool error: ${e.toString()}');
    }
  }

  Future<String> _formatFinalAnswer({required String userMessage, required UserIntent intent, required ToolResult toolResult, required String context}) async {
    if (!toolResult.success) {
      return _handleToolFailure(intent, toolResult.message);
    }
    if (toolResult.data == null && intent.type == IntentType.conversation) {
      return await _generateConversationalResponse(userMessage, context);
    }
    switch (intent.type) {
      case IntentType.weather:
        return await _formatWeatherAnswer(userMessage, toolResult.data, context);
      case IntentType.userData:
      case IntentType.database:
        return await _formatDatabaseAnswer(userMessage, toolResult, context);
      case IntentType.conversation:
        return toolResult.data ?? _getFallbackResponse();
    }
  }

  Future<String> _formatWeatherAnswer(String userMessage, String? weatherData, String context) async {
    if (weatherData == null) return 'Weather data not available.';
    try {
      final prompt = 'You are a friendly travel assistant. The user asked about weather.\n\n$weatherData\n\nUser: "$userMessage"\n\nProvide a natural response with travel recommendations.';
      final response = await _gemini.text(prompt);
      return response?.output ?? weatherData;
    } catch (e) {
      return weatherData;
    }
  }

  Future<String> _formatDatabaseAnswer(String userMessage, ToolResult toolResult, String context) async {
    if (toolResult.data == null) return 'No data available.';
    try {
      final table = toolResult.metadata?['table'] ?? 'database';
      final count = toolResult.metadata?['count'] ?? 0;
      final prompt = 'You are a helpful travel assistant.\n\nUSER: "$userMessage"\n\nRESULTS ($count from $table):\n${toolResult.data}\n\nContext: $context\n\nProvide helpful recommendations.';
      final response = await _gemini.text(prompt);
      return response?.output ?? toolResult.data!;
    } catch (e) {
      return toolResult.data!;
    }
  }

  Future<String> _generateConversationalResponse(String userMessage, String context) async {
    try {
      final systemPrompt = 'You are an AI Travel Assistant for GoTravel. You can help with weather, packages, places, hotels, bookings, favorites, and payments.\n\nContext: $context\n\nUser: $userMessage';
      final response = await _gemini.text(systemPrompt);
      return response?.output ?? _getFallbackResponse();
    } catch (e) {
      return _getFallbackResponse();
    }
  }

  String _handleToolFailure(UserIntent intent, String errorMessage) {
    switch (intent.type) {
      case IntentType.weather:
        return 'Could not get weather. Please specify a location like: "What is the weather in Dhaka?"';
      case IntentType.userData:
        return 'Please make sure you are logged in to view your personal data.';
      case IntentType.database:
        return 'I had trouble finding that information.\n\nTry asking:\n${DynamicDatabaseTool.getExampleQueries()}';
      case IntentType.conversation:
        return _getFallbackResponse();
    }
  }

  String _extractLocation(String message) {
    final words = message.split(' ');
    final prep = ['in', 'at', 'near', 'around', 'to'];
    for (int i = 0; i < words.length - 1; i++) {
      if (prep.contains(words[i].toLowerCase())) {
        return words[i + 1].replaceAll(RegExp(r'[^\w\s]'), '');
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