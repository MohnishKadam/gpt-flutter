import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 1)
class Message {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final MessageRole role;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final List<String>? imageUrls;

  @HiveField(5)
  final String? conversationId;

  @HiveField(6)
  final bool isLoading;

  @HiveField(7)
  final String? error;

  Message({
    String? id,
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.imageUrls,
    this.conversationId,
    this.isLoading = false,
    this.error,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Message copyWith({
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    List<String>? imageUrls,
    String? conversationId,
    bool? isLoading,
    String? error,
  }) {
    return Message(
      id: id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      imageUrls: imageUrls ?? this.imageUrls,
      conversationId: conversationId ?? this.conversationId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'imageUrls': imageUrls,
      'conversationId': conversationId,
      'isLoading': isLoading,
      'error': error,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      role: MessageRole.values.firstWhere((e) => e.name == json['role']),
      timestamp: DateTime.parse(json['timestamp']),
      imageUrls: json['imageUrls']?.cast<String>(),
      conversationId: json['conversationId'],
      isLoading: json['isLoading'] ?? false,
      error: json['error'],
    );
  }

  // Convert to the current project's message format
  Map<String, dynamic> toCurrentFormat() {
    return {
      'text': content,
      'isUser': role == MessageRole.user,
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
      'error': error,
    };
  }

  // Create from current project's message format
  factory Message.fromCurrentFormat(Map<String, dynamic> json) {
    return Message(
      content: json['text'] ?? '',
      role: json['isUser'] == true ? MessageRole.user : MessageRole.assistant,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isLoading: json['isLoading'] ?? false,
      error: json['error'],
    );
  }
}

@HiveType(typeId: 2)
enum MessageRole {
  @HiveField(0)
  user,
  @HiveField(1)
  assistant,
  @HiveField(2)
  system,
}
