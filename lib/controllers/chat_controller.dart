import 'package:chatgpt/models/message.dart';
import 'package:chatgpt/models/ai_model.dart';
import 'package:chatgpt/models/conversation.dart';
import 'package:chatgpt/services/gemini_service.dart';
import 'package:chatgpt/services/chat_repository.dart';
import 'package:chatgpt/controllers/drawer_search_controller.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final messages = <Message>[].obs;
  final isLoading = false.obs;
  final currentMessage = ''.obs;
  final currentConversationId = ''.obs;
  final GeminiService _geminiService = Get.find<GeminiService>();
  final ChatRepository _chatRepository = Get.find<ChatRepository>();

  @override
  void onInit() {
    super.onInit();
    // Listen to conversations stream for real-time updates
    _chatRepository.conversationsStream.listen((conversations) {
      // Update drawer when conversations change
      _refreshDrawer();
    });
  }

  void addMessage(Message message) {
    messages.add(message);
  }

  void addUserMessage(String text) {
    final message = Message(
      content: text,
      role: MessageRole.user,
    );
    addMessage(message);
  }

  void addAIMessage(String text) {
    final message = Message(
      content: text,
      role: MessageRole.assistant,
    );
    addMessage(message);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    addUserMessage(text);
    isLoading.value = true;

    try {
      // Get the default model (you can modify this to use a specific model)
      const model = AIModel.gemini15Flash;
      final response = await _geminiService.chatCompletion(
        messages: messages.toList(),
        model: model,
      );
      addAIMessage(response);

      // Save conversation after both user and AI messages are added
      print('💾 Saving conversation after message exchange...');
      await _saveCurrentConversation();

      // Force refresh the drawer to show the new conversation
      await _refreshDrawer();
    } catch (e) {
      String errorMessage = 'Sorry, I encountered an error. Please try again.';

      if (e.toString().contains('Rate limit exceeded')) {
        errorMessage =
            'Rate limit exceeded. Please wait a few minutes before trying again. The free tier allows 60 requests per minute.';
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            'Request timed out. Please check your internet connection and try again.';
      } else if (e.toString().contains('API key')) {
        errorMessage =
            'API configuration error. Please check your Gemini API key.';
      }

      addAIMessage(errorMessage);
      print('Error sending message: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearMessages() {
    messages.clear();
  }

  void updateCurrentMessage(String text) {
    currentMessage.value = text;
  }

  void clearCurrentMessage() {
    currentMessage.value = '';
  }

  List<Message> getMessages() {
    return messages.toList();
  }

  bool get hasMessages => messages.isNotEmpty;

  // Start a new conversation
  void startNewConversation() {
    messages.clear();
    currentConversationId.value = '';
    currentMessage.value = '';
  }

  // Load conversation by ID
  Future<void> loadConversation(String conversationId) async {
    try {
      final conversation =
          await _chatRepository.getConversation(conversationId);
      if (conversation != null) {
        messages.value = conversation.messages;
        currentConversationId.value = conversationId;
      }
    } catch (e) {
      print('Error loading conversation: $e');
    }
  }

  // Save current conversation
  Future<void> _saveCurrentConversation() async {
    try {
      if (messages.isEmpty) return;

      print('💾 Saving current conversation...');
      print('📝 Messages count: ${messages.length}');
      print('🆔 Current conversation ID: ${currentConversationId.value}');

      final conversation = Conversation(
        id: currentConversationId.value.isEmpty
            ? null
            : currentConversationId.value,
        title: _generateConversationTitle(),
        messages: messages.toList(),
        model: AIModel.gemini15Flash,
      );

      print('📝 Generated title: ${conversation.title}');

      final savedId = await _chatRepository.saveConversation(conversation);
      currentConversationId.value = savedId;
      print('✅ Conversation saved with ID: $savedId');
    } catch (e) {
      print('❌ Error saving conversation: $e');
    }
  }

  // Generate conversation title from first user message
  String _generateConversationTitle() {
    final firstUserMessage =
        messages.where((m) => m.role == MessageRole.user).firstOrNull;

    if (firstUserMessage == null) return 'New Conversation';

    String title = firstUserMessage.content;
    if (title.length > 30) {
      title = '${title.substring(0, 30)}...';
    }

    return title;
  }

  // Update conversation title
  Future<void> updateConversationTitle(String newTitle) async {
    if (currentConversationId.value.isEmpty) return;

    try {
      await _chatRepository.updateConversationTitle(
        currentConversationId.value,
        newTitle,
      );
    } catch (e) {
      print('Error updating conversation title: $e');
    }
  }

  // Delete current conversation
  Future<void> deleteCurrentConversation() async {
    if (currentConversationId.value.isEmpty) return;

    try {
      await _chatRepository.deleteConversation(currentConversationId.value);
      startNewConversation();
    } catch (e) {
      print('Error deleting conversation: $e');
    }
  }

  // Refresh drawer to show updated chat history
  Future<void> _refreshDrawer() async {
    try {
      final drawerController = Get.find<DrawerSearchController>();
      print('🔄 Refreshing drawer chats...');
      await drawerController.refreshChats();
      print('✅ Drawer refreshed successfully');
    } catch (e) {
      print('⚠️ Could not refresh drawer: $e');
      // Try to find the controller again
      try {
        final drawerController = Get.put(DrawerSearchController());
        await drawerController.refreshChats();
        print('✅ Drawer refreshed on second attempt');
      } catch (e2) {
        print('❌ Failed to refresh drawer on second attempt: $e2');
      }
    }
  }

  // Get sync status
  Stream<bool> get syncStatusStream => _chatRepository.syncStatusStream;

  // Get online status
  RxBool get isOnline => _chatRepository.isOnline;

  // Get syncing status
  RxBool get isSyncing => _chatRepository.isSyncing;

  // Manual sync
  Future<void> syncData() async {
    await _chatRepository.syncData();
  }
}
