import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'message.dart';
import 'ai_model.dart';

part 'conversation.g.dart';

@HiveType(typeId: 3)
class Conversation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final List<Message> messages;

  @HiveField(5)
  final AIModel model;

  @HiveField(6)
  final bool isPinned;

  Conversation({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
    AIModel? model,
    this.isPinned = false,
  })  : id = id ?? const Uuid().v4(),
        title = title ?? 'New Conversation',
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        messages = messages ?? [],
        model = model ?? AIModel.gemini15Flash;

  Conversation copyWith({
    String? title,
    DateTime? updatedAt,
    List<Message>? messages,
    AIModel? model,
    bool? isPinned,
  }) {
    return Conversation(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      messages: messages ?? this.messages,
      model: model ?? this.model,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  String get preview {
    if (messages.isEmpty) return 'New conversation';

    final lastUserMessage =
        messages.where((m) => m.role == MessageRole.user).lastOrNull;

    if (lastUserMessage == null) return 'New conversation';

    String preview = lastUserMessage.content;
    if (preview.length > 50) {
      preview = '${preview.substring(0, 50)}...';
    }

    return preview;
  }

  String get smartTitle {
    if (title != 'New Conversation') return title;

    final firstUserMessage =
        messages.where((m) => m.role == MessageRole.user).firstOrNull;

    if (firstUserMessage == null) return 'New conversation';

    String smartTitle = firstUserMessage.content;
    if (smartTitle.length > 30) {
      smartTitle = '${smartTitle.substring(0, 30)}...';
    }

    return smartTitle;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'model': model.name,
      'isPinned': isPinned,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      messages: (json['messages'] as List<dynamic>)
          .map((m) => Message.fromJson(m))
          .toList(),
      model: AIModel.values.firstWhere(
        (e) => e.name == json['model'],
        orElse: () => AIModel.gemini15Flash,
      ),
      isPinned: json['isPinned'] ?? false,
    );
  }
}

extension ListExtensions<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
  T? get firstOrNull => isEmpty ? null : first;
}
