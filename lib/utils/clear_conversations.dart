import 'package:get/get.dart';
import '../controllers/drawer_search_controller.dart';
import '../services/storage_service.dart';

class ClearConversations {
  static final DrawerSearchController _drawerController =
      Get.find<DrawerSearchController>();
  static final StorageService _storageService = Get.find<StorageService>();

  /// Clear all conversations from storage and refresh drawer
  static Future<void> clearAllConversations() async {
    print('🧹 Clearing all conversations...');

    try {
      // Step 1: Clear all conversations from storage
      await _storageService.clearAllConversations();
      print('✅ All conversations cleared from storage');

      // Step 2: Refresh the drawer to reflect changes
      await _drawerController.refreshChats();
      print('✅ Drawer refreshed');

      // Step 3: Verify the drawer is empty
      print('📱 Final drawer state:');
      print('   All chats: ${_drawerController.allChats.length}');
      print('   Filtered chats: ${_drawerController.filteredChats.length}');

      if (_drawerController.filteredChats.isEmpty) {
        print('✅ Sidebar is now empty');
      } else {
        print('❌ Sidebar still has conversations');
      }
    } catch (e) {
      print('❌ Error clearing conversations: $e');
    }
  }

  /// Get current conversation count
  static Future<int> getConversationCount() async {
    try {
      final conversations = await _storageService.loadConversations();
      return conversations.length;
    } catch (e) {
      print('❌ Error getting conversation count: $e');
      return 0;
    }
  }
}
