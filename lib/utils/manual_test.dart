import 'package:get/get.dart';
import '../controllers/drawer_search_controller.dart';
import '../services/storage_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ManualTest {
  static final DrawerSearchController _drawerController =
      Get.find<DrawerSearchController>();
  static final StorageService _storageService = Get.find<StorageService>();

  /// Manually create a test conversation and check if it appears
  static Future<void> createTestConversation() async {
    print('🧪 Creating test conversation manually...');

    try {
      // Step 1: Create a test conversation
      final testConversation = Conversation(
        title: 'Manual Test Conversation',
        messages: [
          Message(
            content: 'This is a manual test message',
            role: MessageRole.user,
          ),
          Message(
            content: 'This is a manual test response from AI',
            role: MessageRole.assistant,
          ),
        ],
      );

      // Step 2: Save the conversation
      print('💾 Saving test conversation...');
      final savedId = await _storageService.saveConversation(testConversation);
      print('✅ Conversation saved with ID: $savedId');

      // Step 3: Refresh drawer
      print('🔄 Refreshing drawer...');
      await _drawerController.refreshChats();

      // Step 4: Check if conversation appears
      print('📱 Checking drawer state:');
      print('   All chats: ${_drawerController.allChats.length}');
      print('   Filtered chats: ${_drawerController.filteredChats.length}');

      if (_drawerController.filteredChats.isNotEmpty) {
        print('✅ Conversations found in drawer:');
        for (int i = 0; i < _drawerController.filteredChats.length; i++) {
          final chat = _drawerController.filteredChats[i];
          print(
              '   ${i + 1}. ${chat.smartTitle} (${chat.messages.length} messages)');
        }
      } else {
        print('❌ No conversations found in drawer');
      }

      // Step 5: Load conversations from storage to verify
      final conversations = await _storageService.loadConversations();
      print('📱 Conversations in storage: ${conversations.length}');

      print('✅ Manual test completed');
    } catch (e) {
      print('❌ Manual test failed: $e');
    }
  }

  /// Clear all conversations and start fresh
  static Future<void> clearAllConversations() async {
    print('🧹 Clearing all conversations...');

    try {
      await _storageService.clearAllConversations();
      await _drawerController.refreshChats();
      print('✅ All conversations cleared');
    } catch (e) {
      print('❌ Error clearing conversations: $e');
    }
  }

  /// Create multiple test conversations
  static Future<void> createMultipleConversations() async {
    print('🧪 Creating multiple test conversations...');

    try {
      final conversations = [
        Conversation(
          title: 'First Test',
          messages: [
            Message(
                content: 'Hello, this is the first test',
                role: MessageRole.user),
            Message(
                content: 'Hi! This is the first response',
                role: MessageRole.assistant),
          ],
        ),
        Conversation(
          title: 'Second Test',
          messages: [
            Message(content: 'How are you today?', role: MessageRole.user),
            Message(
                content: 'I\'m doing well, thank you!',
                role: MessageRole.assistant),
          ],
        ),
        Conversation(
          title: 'Third Test',
          messages: [
            Message(content: 'What is Flutter?', role: MessageRole.user),
            Message(
                content: 'Flutter is a UI toolkit by Google',
                role: MessageRole.assistant),
          ],
        ),
      ];

      for (int i = 0; i < conversations.length; i++) {
        print('💾 Saving conversation ${i + 1}...');
        await _storageService.saveConversation(conversations[i]);
      }

      print('🔄 Refreshing drawer...');
      await _drawerController.refreshChats();

      print('📱 Final drawer state:');
      print('   All chats: ${_drawerController.allChats.length}');
      print('   Filtered chats: ${_drawerController.filteredChats.length}');

      print('✅ Multiple conversations created');
    } catch (e) {
      print('❌ Error creating multiple conversations: $e');
    }
  }
}
