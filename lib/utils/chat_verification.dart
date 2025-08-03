import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/drawer_search_controller.dart';
import '../services/storage_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatVerification {
  static final ChatController _chatController = Get.find<ChatController>();
  static final DrawerSearchController _drawerController =
      Get.find<DrawerSearchController>();
  static final StorageService _storageService = Get.find<StorageService>();

  /// Verify that chat saving and drawer display works correctly
  static Future<void> verifyChatFlow() async {
    print('🧪 Verifying chat flow...');

    try {
      // Step 1: Check current state
      print('📱 Current conversations:');
      final initialConversations = await _storageService.loadConversations();
      print('   Found ${initialConversations.length} conversations');

      // Step 2: Simulate a chat conversation
      print('📝 Simulating chat conversation...');
      _chatController.clearMessages();
      _chatController.addUserMessage('Hello, how are you?');
      _chatController.addAIMessage(
          'Hi! I\'m doing well, thank you for asking. How can I help you today?');

      // Step 3: Save the conversation manually
      print('💾 Saving conversation...');
      final conversation = Conversation(
        title: 'Test Conversation',
        messages: _chatController.messages.toList(),
      );
      await _storageService.saveConversation(conversation);

      // Step 4: Refresh drawer
      print('🔄 Refreshing drawer...');
      await _drawerController.refreshChats();

      // Step 5: Verify the conversation appears
      print('📱 Checking drawer conversations:');
      print('   Filtered chats: ${_drawerController.filteredChats.length}');
      print('   All chats: ${_drawerController.allChats.length}');

      // Step 6: Load conversations again to verify
      final updatedConversations = await _storageService.loadConversations();
      print('📱 Updated conversations after save:');
      print('   Found ${updatedConversations.length} conversations');

      // Step 7: Check if our conversation is there with correct title
      final testConv = updatedConversations.firstWhereOrNull(
          (conv) => conv.smartTitle.contains('Hello, how are you?'));

      if (testConv != null) {
        print('✅ Conversation found in storage');
        print('   ID: ${testConv.id}');
        print('   Title: ${testConv.title}');
        print('   Smart Title: ${testConv.smartTitle}');
        print('   Messages: ${testConv.messages.length}');
        print('   Updated: ${testConv.updatedAt}');
      } else {
        print('❌ Conversation not found in storage');
      }

      print('✅ Chat flow verification completed');
    } catch (e) {
      print('❌ Chat flow verification failed: $e');
    }
  }

  /// Test the complete flow: send message → save → appear in drawer
  static Future<void> testCompleteFlow() async {
    print('🧪 Testing complete chat flow...');

    try {
      // Step 1: Clear current messages
      _chatController.clearMessages();
      print('📝 Cleared current messages');

      // Step 2: Add user message (this should become the title)
      final userMessage = 'What is Flutter?';
      _chatController.addUserMessage(userMessage);
      print('📝 Added user message: "$userMessage"');

      // Step 3: Add AI response
      _chatController.addAIMessage(
          'Flutter is a UI toolkit by Google for building natively compiled applications for mobile, web, and desktop from a single codebase.');
      print('📝 Added AI response');

      // Step 4: Save conversation manually
      print('💾 Saving conversation...');
      final conversation = Conversation(
        title: 'What is Flutter?',
        messages: _chatController.messages.toList(),
      );
      await _storageService.saveConversation(conversation);

      // Step 5: Refresh drawer
      print('🔄 Refreshing drawer...');
      await _drawerController.refreshChats();

      // Step 6: Check if conversation appears in drawer
      print('📱 Checking drawer state:');
      print('   Filtered chats: ${_drawerController.filteredChats.length}');
      print('   All chats: ${_drawerController.allChats.length}');

      if (_drawerController.filteredChats.isNotEmpty) {
        final latestChat = _drawerController.filteredChats.first;
        print('✅ Latest conversation in drawer:');
        print('   Title: ${latestChat.title}');
        print('   Smart Title: ${latestChat.smartTitle}');
        print('   Messages: ${latestChat.messages.length}');
      } else {
        print('❌ No conversations found in drawer');
      }

      print('✅ Complete flow test completed');
    } catch (e) {
      print('❌ Complete flow test failed: $e');
    }
  }

  /// Get current status of all components
  static String getStatus() {
    final chatCount = _drawerController.filteredChats.length;
    final allChatCount = _drawerController.allChats.length;
    final currentMessages = _chatController.messages.length;

    return 'Status:\n'
        '• Current messages: $currentMessages\n'
        '• Conversations in drawer: $chatCount\n'
        '• Total conversations: $allChatCount\n'
        '• Drawer controller: ${Get.isRegistered<DrawerSearchController>() ? "✅" : "❌"}\n'
        '• Storage service: ${Get.isRegistered<StorageService>() ? "✅" : "❌"}';
  }
}
