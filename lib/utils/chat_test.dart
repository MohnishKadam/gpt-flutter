import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/drawer_search_controller.dart';
import '../services/storage_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatTest {
  static final ChatController _chatController = Get.find<ChatController>();
  static final DrawerSearchController _drawerController =
      Get.find<DrawerSearchController>();
  static final StorageService _storageService = Get.find<StorageService>();

  /// Test creating a conversation and checking if it appears in sidebar
  static Future<void> testChatCreation() async {
    print('🧪 Testing chat creation and sidebar update...');

    try {
      // Step 1: Check current conversations
      print('📱 Current conversations before test:');
      final initialConversations = await _storageService.loadConversations();
      print('   Found ${initialConversations.length} conversations');

      // Step 2: Create a test conversation manually
      print('📝 Creating test conversation...');
      final testConversation = Conversation(
        title: 'Test Chat Creation',
        messages: [
          Message(
            content: 'This is a test message for chat creation',
            role: MessageRole.user,
          ),
          Message(
            content: 'This is a test response from AI',
            role: MessageRole.assistant,
          ),
        ],
      );

      // Step 3: Save the conversation
      final savedId = await _storageService.saveConversation(testConversation);
      print('✅ Conversation saved with ID: $savedId');

      // Step 4: Refresh drawer
      print('🔄 Refreshing drawer...');
      await _drawerController.refreshChats();

      // Step 5: Check if conversation appears in drawer
      print('📱 Checking drawer conversations:');
      print('   Filtered chats: ${_drawerController.filteredChats.length}');
      print('   All chats: ${_drawerController.allChats.length}');

      // Step 6: Load conversations again to verify
      final updatedConversations = await _storageService.loadConversations();
      print('📱 Updated conversations after test:');
      print('   Found ${updatedConversations.length} conversations');

      // Step 7: Check if our test conversation is there
      final testConv = updatedConversations
          .firstWhereOrNull((conv) => conv.title == 'Test Chat Creation');

      if (testConv != null) {
        print('✅ Test conversation found in storage');
        print('   ID: ${testConv.id}');
        print('   Title: ${testConv.title}');
        print('   Messages: ${testConv.messages.length}');
      } else {
        print('❌ Test conversation not found in storage');
      }
    } catch (e) {
      print('❌ Chat creation test failed: $e');
    }
  }

  /// Test sending a message through the chat controller
  static Future<void> testSendMessage() async {
    print('🧪 Testing send message through chat controller...');

    try {
      // Step 1: Clear current messages
      _chatController.clearMessages();
      print('📝 Cleared current messages');

      // Step 2: Add a test message
      _chatController.addUserMessage('Test message from chat test utility');
      print('📝 Added user message');

      // Step 3: Add AI response
      _chatController.addAIMessage('Test AI response from chat test utility');
      print('📝 Added AI message');

      // Step 4: Save conversation manually
      print('💾 Saving conversation...');
      final conversation = Conversation(
        title: 'Test Send Message',
        messages: _chatController.messages.toList(),
      );
      await _storageService.saveConversation(conversation);

      // Step 5: Refresh drawer
      print('🔄 Refreshing drawer...');
      await _drawerController.refreshChats();

      print('✅ Send message test completed');
    } catch (e) {
      print('❌ Send message test failed: $e');
    }
  }

  /// Test drawer refresh functionality
  static Future<void> testDrawerRefresh() async {
    print('🧪 Testing drawer refresh...');

    try {
      print('📱 Conversations before refresh:');
      print('   Filtered: ${_drawerController.filteredChats.length}');
      print('   All: ${_drawerController.allChats.length}');

      await _drawerController.refreshChats();

      print('📱 Conversations after refresh:');
      print('   Filtered: ${_drawerController.filteredChats.length}');
      print('   All: ${_drawerController.allChats.length}');

      print('✅ Drawer refresh test completed');
    } catch (e) {
      print('❌ Drawer refresh test failed: $e');
    }
  }

  /// Get current chat status
  static String getChatStatus() {
    final chatCount = _drawerController.filteredChats.length;
    final allChatCount = _drawerController.allChats.length;
    final currentMessages = _chatController.messages.length;

    return 'Chat Status:\n'
        '• Current messages: $currentMessages\n'
        '• Filtered chats: $chatCount\n'
        '• All chats: $allChatCount';
  }
}
