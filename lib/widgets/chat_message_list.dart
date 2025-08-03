import 'package:chatgpt/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';

class ChatMessageList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;

  const ChatMessageList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(
          message: message['text'],
          isUser: message['isUser'],
        );
      },
    );
  }
}
