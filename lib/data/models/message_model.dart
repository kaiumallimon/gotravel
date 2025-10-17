enum MessageRole {
  user,
  assistant,
  system;

  String get value {
    switch (this) {
      case MessageRole.user:
        return 'user';
      case MessageRole.assistant:
        return 'assistant';
      case MessageRole.system:
        return 'system';
    }
  }

  static MessageRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final Map<String, dynamic>? metadata;
  final int tokensUsed;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.metadata,
    this.tokensUsed = 0,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: MessageRole.fromString(json['role'] as String),
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      tokensUsed: json['tokens_used'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role.value,
      'content': content,
      'metadata': metadata,
      'tokens_used': tokensUsed,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    MessageRole? role,
    String? content,
    Map<String, dynamic>? metadata,
    int? tokensUsed,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
