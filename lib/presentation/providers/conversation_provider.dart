import 'package:flutter/material.dart';
import 'package:gotravel/data/models/conversation_model.dart';
import 'package:gotravel/data/models/message_model.dart';
import 'package:gotravel/data/services/remote/conversation_service.dart';
import 'package:gotravel/data/services/ai/ai_service.dart';

class ConversationProvider with ChangeNotifier {
  final ConversationService _conversationService = ConversationService();
  final AIService _aiService = AIService();

  List<ConversationModel> _conversations = [];
  ConversationModel? _activeConversation;
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  List<ConversationModel> get conversations => _conversations;
  ConversationModel? get activeConversation => _activeConversation;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  /// Load all conversations for the current user
  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _conversationService.getUserConversations();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new conversation
  Future<ConversationModel?> createNewConversation({String? title}) async {
    try {
      final conversation = await _conversationService.createConversation(
        title: title ?? 'New Conversation',
      );
      _conversations.insert(0, conversation);
      notifyListeners();
      return conversation;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Set active conversation and load its messages
  Future<void> setActiveConversation(ConversationModel conversation) async {
    _activeConversation = conversation;
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _conversationService.getConversationMessages(conversation.id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send a message and get AI response
  Future<void> sendMessage(String content) async {
    if (_activeConversation == null || content.trim().isEmpty) return;

    _isSending = true;
    notifyListeners();

    try {
      // Add user message
      final userMessage = await _conversationService.addMessage(
        conversationId: _activeConversation!.id,
        role: MessageRole.user,
        content: content.trim(),
      );
      _messages.add(userMessage);
      notifyListeners();

      // Get conversation history for context
      final history = _messages.map((msg) => {
        'role': msg.role.value,
        'content': msg.content,
      }).toList();

      // Get AI response
      final aiResponse = await _aiService.chat(content.trim(), history);

      // Add AI message
      final assistantMessage = await _conversationService.addMessage(
        conversationId: _activeConversation!.id,
        role: MessageRole.assistant,
        content: aiResponse,
      );
      _messages.add(assistantMessage);

      // Update conversation title if it's the first message
      if (_messages.where((m) => m.role == MessageRole.user).length == 1) {
        final title = content.length > 50 
            ? '${content.substring(0, 50)}...' 
            : content;
        await _conversationService.updateConversationTitle(
          _activeConversation!.id,
          title,
        );
        _activeConversation = _activeConversation!.copyWith(title: title);
        
        // Update in conversations list
        final index = _conversations.indexWhere((c) => c.id == _activeConversation!.id);
        if (index != -1) {
          _conversations[index] = _activeConversation!;
        }
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _conversationService.deleteConversation(conversationId);
      _conversations.removeWhere((c) => c.id == conversationId);
      
      if (_activeConversation?.id == conversationId) {
        _activeConversation = null;
        _messages = [];
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clear active conversation
  void clearActiveConversation() {
    _activeConversation = null;
    _messages = [];
    notifyListeners();
  }
}
