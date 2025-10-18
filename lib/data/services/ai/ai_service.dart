import 'dart:convert';
import 'package:http/http.dart' as http;

/// AI Service - Connects to GoTravel FastAPI Backend
/// 
/// The backend handles:
/// - Intent classification
/// - Tool execution (database queries, weather, etc.)
/// - Natural language response generation
/// 
/// The Flutter app handles:
/// - Storing messages in Supabase (done by ConversationProvider)
/// - UI/UX
class AIService {
  static const String baseUrl = 'https://gotravel-server-ww0k.onrender.com';
  
  /// Send a message to the AI backend and get a response
  /// 
  /// Parameters:
  /// - userMessage: The user's question/query
  /// - conversationHistory: Previous messages for context (not used by backend currently)
  /// 
  /// Returns: The AI's response text
  Future<String> chat(
    String userMessage,
    List<Map<String, String>> conversationHistory,
  ) async {
    try {
      print('\n🤖 === AI BACKEND CALL ===');
      print('📨 User: "$userMessage"');
      
      // Generate unique session ID for this conversation
      final sessionId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';
      
      // Call the backend API
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': userMessage,
          'session_id': sessionId,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out after 30 seconds');
        },
      );

      print('📡 Response Status: ${response.statusCode}');

      // Handle successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          final aiResponse = data['response'] as String;
          print('✅ AI Response: ${aiResponse.substring(0, aiResponse.length > 100 ? 100 : aiResponse.length)}...');
          print('🔧 Tools Used: ${data['tools_used']}');
          print('🤖 === END ===\n');
          return aiResponse;
        } else {
          // Backend returned success: false
          final error = data['error'] ?? 'Unknown error';
          print('❌ Backend Error: $error\n');
          return '❌ Sorry, something went wrong: $error\n\n💡 Try asking in a different way or try again later.';
        }
      }

      // Handle HTTP errors
      print('❌ HTTP Error: ${response.statusCode}');
      print('Response: ${response.body}\n');
      
      if (response.statusCode == 404) {
        return '❌ Service not found. Please check if the backend is running.';
      } else if (response.statusCode >= 500) {
        return '❌ Server error. The backend is having issues. Please try again later.';
      } else {
        return '❌ Request failed with status ${response.statusCode}. Please try again.';
      }
      
    } on http.ClientException catch (e) {
      print('❌ Network Error: $e\n');
      return '📡 Network error. Please check your internet connection and try again.';
    } catch (e) {
      print('❌ Exception: $e\n');
      
      if (e.toString().contains('timeout') || e.toString().contains('timed out')) {
        return '⏱️ The request timed out. The server might be slow or unavailable.\n\n💡 Please try again in a moment.';
      }
      
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        return '📡 Cannot connect to the server. Please check your internet connection.';
      }
      
      return '❌ An unexpected error occurred.\n\n💡 Please try again or contact support if the issue persists.';
    }
  }

  /// Check backend health status
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}
