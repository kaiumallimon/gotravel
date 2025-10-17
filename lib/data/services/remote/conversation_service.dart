import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotravel/data/models/conversation_model.dart';
import 'package:gotravel/data/models/message_model.dart';

class ConversationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all conversations for current user
  Future<List<ConversationModel>> getUserConversations() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('conversations')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => ConversationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  // Create new conversation
  Future<ConversationModel> createConversation({String? title}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('conversations')
          .insert({
            'user_id': userId,
            'title': title ?? 'New Conversation',
            'is_active': true,
          })
          .select()
          .single();

      return ConversationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  // Update conversation title
  Future<void> updateConversationTitle(String conversationId, String title) async {
    try {
      await _supabase
          .from('conversations')
          .update({'title': title})
          .eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to update conversation: $e');
    }
  }

  // Delete conversation (soft delete)
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _supabase
          .from('conversations')
          .update({'is_active': false})
          .eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // Get messages for a conversation
  Future<List<MessageModel>> getConversationMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  // Add message to conversation
  Future<MessageModel> addMessage({
    required String conversationId,
    required MessageRole role,
    required String content,
    Map<String, dynamic>? metadata,
    int tokensUsed = 0,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'role': role.value,
            'content': content,
            'metadata': metadata,
            'tokens_used': tokensUsed,
          })
          .select()
          .single();

      // Update conversation's updated_at timestamp
      await _supabase
          .from('conversations')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', conversationId);

      return MessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add message: $e');
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .delete()
          .eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // Get last message from conversation (for preview)
  Future<MessageModel?> getLastMessage(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return MessageModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
