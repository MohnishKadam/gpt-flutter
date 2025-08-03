import 'package:chatgpt/models/message.dart';
import 'package:chatgpt/models/ai_model.dart';
import 'package:chatgpt/services/gemini_service.dart';
import 'package:get/get.dart';

class ChatServices {
  static final GeminiService _geminiService = Get.find<GeminiService>();

  static Future<String> generateAIResponse(
      String prompt, List<Message> history) async {
    try {
      // Combine history with current prompt
      List<Message> messages = [...history];

      // Add current user message
      messages.add(Message(
        content: prompt,
        role: MessageRole.user,
      ));

      // Use the default model
      const model = AIModel.gemini15Flash;

      final response = await _geminiService.chatCompletion(
        messages: messages,
        model: model,
      );

      return response;
    } catch (e) {
      print('Error generating AI response: $e');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  static Future<void> saveChat(String chatId, List<Message> messages) async {
    try {
      // This would typically save to Firebase or local storage
      // For now, we'll just print the messages
      print('Saving chat with ID: $chatId');
      print('Messages: ${messages.length}');
    } catch (e) {
      print('Error saving chat: $e');
    }
  }

  static List<Message> parseMessages(List<dynamic> rawMessages) {
    return rawMessages.map((msg) {
      if (msg is Map<String, dynamic>) {
        return Message.fromJson(msg);
      } else if (msg is Message) {
        return msg;
      } else {
        // Fallback for other formats
        return Message(
          content: msg.toString(),
          role: MessageRole.user,
        );
      }
    }).toList();
  }

  static Map<String, dynamic> messageToJson(Message message) {
    return message.toJson();
  }

  static Message jsonToMessage(Map<String, dynamic> json) {
    return Message.fromJson(json);
  }
}
