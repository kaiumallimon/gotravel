import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gotravel/data/services/ai/weather_tool.dart';
import 'package:gotravel/data/services/ai/travel_data_tool.dart';

class AIService {
  final Gemini _gemini = Gemini.instance;

  /// Process user message and generate AI response with tool calling
  Future<String> chat(String userMessage, List<Map<String, String>> conversationHistory) async {
    try {
      // Detect if user is asking about weather
      if (_isWeatherQuery(userMessage)) {
        final location = _extractLocation(userMessage);
        if (location.isNotEmpty) {
          final weatherData = await WeatherTool.getCurrentWeather(location);
          final weatherInfo = WeatherTool.formatWeatherForAI(weatherData);
          
          // Ask Gemini to format the response nicely
          final prompt = 'Based on this weather data, provide a friendly and helpful response to the user:\n\n$weatherInfo\n\nUser asked: "$userMessage"\n\nProvide a natural, conversational response.';
          
          try {
            final response = await _gemini.text(prompt);
            return response?.output ?? weatherInfo;
          } catch (e) {
            // If Gemini fails, return formatted data directly
            return weatherInfo;
          }
        }
      }

      // Detect if user is asking about packages
      if (_isPackageQuery(userMessage)) {
        final country = _extractCountry(userMessage);
        final packagesData = await TravelDataTool.getCheapestPackages(
          country: country,
          limit: 5,
        );
        final packagesInfo = TravelDataTool.formatPackagesForAI(packagesData);
        
        final prompt = 'Based on this travel package data, provide a friendly and helpful response to the user:\n\n$packagesInfo\n\nUser asked: "$userMessage"\n\nProvide recommendations and explain why these packages are good choices.';
        
        try {
          final response = await _gemini.text(prompt);
          return response?.output ?? packagesInfo;
        } catch (e) {
          // If Gemini fails, return formatted data directly
          return packagesInfo;
        }
      }

      // Detect if user is asking about places
      if (_isPlaceQuery(userMessage)) {
        final searchTerm = _extractSearchTerm(userMessage);
        final placesData = await TravelDataTool.searchPlaces(searchTerm);
        final placesInfo = TravelDataTool.formatPlacesForAI(placesData);
        
        final prompt = 'Based on this places data, provide a friendly and helpful response to the user:\n\n$placesInfo\n\nUser asked: "$userMessage"\n\nProvide helpful information about these places.';
        
        try {
          final response = await _gemini.text(prompt);
          return response?.output ?? placesInfo;
        } catch (e) {
          // If Gemini fails, return formatted data directly
          return placesInfo;
        }
      }

      // Detect if user is asking about hotels
      if (_isHotelQuery(userMessage)) {
        final location = _extractLocation(userMessage);
        final hotelsData = await TravelDataTool.searchHotels(
          city: location,
          limit: 5,
        );
        final hotelsInfo = TravelDataTool.formatHotelsForAI(hotelsData);
        
        final prompt = 'Based on this hotel data, provide a friendly and helpful response to the user:\n\n$hotelsInfo\n\nUser asked: "$userMessage"\n\nProvide helpful recommendations about these hotels.';
        
        try {
          final response = await _gemini.text(prompt);
          return response?.output ?? hotelsInfo;
        } catch (e) {
          // If Gemini fails, return formatted data directly
          return hotelsInfo;
        }
      }

      // General travel assistant response - try Gemini first, fallback to helpful message
      final conversationContext = conversationHistory
          .map((msg) => '${msg['role']}: ${msg['content']}')
          .join('\n');
      
      final systemPrompt = 'You are a helpful travel assistant for GoTravel app. You help users with travel recommendations, weather information, finding tour packages, discovering places to visit, and hotel recommendations.\n\nBe friendly, concise, and helpful.\n\nPrevious conversation:\n$conversationContext\n\nUser: $userMessage\n\nAssistant:';
      
      try {
        final response = await _gemini.text(systemPrompt);
        return response?.output ?? _getFallbackResponse(userMessage);
      } catch (e) {
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      // Check if it's an API key error
      if (e.toString().contains('404') || e.toString().contains('API key')) {
        return '⚠️ API Configuration Error\n\nThe Gemini API key is not configured properly. Please:\n\n1. Get a free API key from https://makersuite.google.com/app/apikey\n2. Add it to your .env file as GEMINI_API_KEY\n3. Restart the app\n\nIn the meantime, I can still help you with:\n• Weather information\n• Finding tour packages\n• Discovering places\n• Hotel recommendations\n\nTry asking: "Show me packages in Bangladesh" or "Find hotels in Dhaka"';
      }
      return 'I encountered an error: ${e.toString().split('\n').first}. Please try again or ask something else.';
    }
  }

  // Fallback response when Gemini is unavailable
  String _getFallbackResponse(String userMessage) {
    return '''Hello! I'm your AI Travel Assistant. 

I can help you with:

🌤️ **Weather Information**
Try: "What's the weather in Cox's Bazar?"

📦 **Tour Packages** 
Try: "Show me cheapest packages in Bangladesh"

🏞️ **Places to Visit**
Try: "Popular places to visit"

🏨 **Hotels**
Try: "Find hotels in Dhaka"

What would you like to know about?''';
  }

  // Helper methods to detect query intent
  bool _isWeatherQuery(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('weather') ||
           lowerMessage.contains('temperature') ||
           lowerMessage.contains('forecast') ||
           lowerMessage.contains('hot') ||
           lowerMessage.contains('cold') ||
           lowerMessage.contains('rain');
  }

  bool _isPackageQuery(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('package') ||
           lowerMessage.contains('tour') ||
           lowerMessage.contains('trip') ||
           lowerMessage.contains('cheapest') ||
           lowerMessage.contains('affordable');
  }

  bool _isPlaceQuery(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('place') ||
           lowerMessage.contains('visit') ||
           lowerMessage.contains('attraction') ||
           lowerMessage.contains('see') ||
           lowerMessage.contains('destination');
  }

  bool _isHotelQuery(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('hotel') ||
           lowerMessage.contains('stay') ||
           lowerMessage.contains('accommodation') ||
           lowerMessage.contains('resort');
  }

  // Helper methods to extract information from user query
  String _extractLocation(String message) {
    // Simple extraction - look for common location patterns
    final words = message.split(' ');
    final commonPrepositions = ['in', 'at', 'near', 'around'];
    
    for (int i = 0; i < words.length - 1; i++) {
      if (commonPrepositions.contains(words[i].toLowerCase())) {
        return words[i + 1].replaceAll(RegExp(r'[^\w\s]'), '');
      }
    }
    
    return '';
  }

  String _extractCountry(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Common countries in the region
    const countries = [
      'bangladesh',
      'india',
      'nepal',
      'bhutan',
      'sri lanka',
      'maldives',
      'thailand',
      'malaysia',
      'singapore',
    ];
    
    for (final country in countries) {
      if (lowerMessage.contains(country)) {
        return country;
      }
    }
    
    return '';
  }

  String _extractSearchTerm(String message) {
    // Remove common question words
    var cleaned = message.toLowerCase()
        .replaceAll(RegExp(r'\b(what|where|when|how|show|find|me|the|a|an|in|at)\b'), '')
        .trim();
    
    return cleaned.isEmpty ? message : cleaned;
  }
}
