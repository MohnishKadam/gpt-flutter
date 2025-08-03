import 'package:get/get.dart';
import '../controllers/drawer_search_controller.dart';
import '../services/storage_service.dart';

class DebugDrawer {
  static final DrawerSearchController _drawerController =
      Get.find<DrawerSearchController>();
  static final StorageService _storageService = Get.find<StorageService>();

  /// Debug the drawer state and conversations
  static Future<void> debugDrawerState() async {
    print('🔍 Debugging drawer state...');

    try {
      // Check if drawer controller exists
      print(
          '📱 Drawer controller registered: ${Get.isRegistered<DrawerSearchController>()}');

      // Check current conversations in storage
      print('📂 Loading conversations from storage...');
      final conversations = await _storageService.loadConversations();
      print('📱 Found ${conversations.length} conversations in storage');

      // Print each conversation
      for (int i = 0; i < conversations.length; i++) {
        final conv = conversations[i];
        print('📋 Conversation ${i + 1}:');
        print('   ID: ${conv.id}');
        print('   Title: ${conv.title}');
        print('   Smart Title: ${conv.smartTitle}');
        print('   Messages: ${conv.messages.length}');
        print('   Updated: ${conv.updatedAt}');
      }

      // Check drawer controller state
      print('🎯 Drawer controller state:');
      print('   All chats: ${_drawerController.allChats.length}');
      print('   Filtered chats: ${_drawerController.filteredChats.length}');
      print('   Search query: "${_drawerController.searchQuery.value}"');

      // Force refresh drawer
      print('🔄 Forcing drawer refresh...');
      await _drawerController.refreshChats();

      // Check state after refresh
      print('📱 State after refresh:');
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
    } catch (e) {
      print('❌ Error debugging drawer state: $e');
    }
  }

  /// Force refresh the drawer
  static Future<void> forceRefreshDrawer() async {
    print('🔄 Force refreshing drawer...');
    try {
      await _drawerController.refreshChats();
      print('✅ Drawer refreshed successfully');
      print('📱 Current chat count: ${_drawerController.filteredChats.length}');
    } catch (e) {
      print('❌ Error refreshing drawer: $e');
    }
  }

  /// Get drawer status
  static String getDrawerStatus() {
    final allChats = _drawerController.allChats.length;
    final filteredChats = _drawerController.filteredChats.length;
    final searchQuery = _drawerController.searchQuery.value;

    return 'Drawer Status:\n'
        '• All chats: $allChats\n'
        '• Filtered chats: $filteredChats\n'
        '• Search query: "$searchQuery"\n'
        '• Controller registered: ${Get.isRegistered<DrawerSearchController>() ? "✅" : "❌"}';
  }
}
