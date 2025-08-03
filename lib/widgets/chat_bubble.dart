import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Container(
      margin: EdgeInsets.only(
        left: isUser ? 50 : 0,
        right: isUser ? 0 : 50,
        top: 8,
        bottom: 8,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUser
            ? (themeController.isDarkMode.value
                ? Colors.grey.withOpacity(0.2)
                : Colors.grey.withOpacity(0.7))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(27),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
