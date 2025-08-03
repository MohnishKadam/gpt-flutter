import 'package:get/get.dart';
import 'package:chatgpt/models/conversation.dart';
import 'package:chatgpt/services/chat_repository.dart';

class DrawerSearchController extends GetxController {
  final isDrawerOpen = false.obs;
  final searchQuery = ''.obs;
  final filteredChats = <Conversation>[].obs;
  final allChats = <Conversation>[].obs;
  final isSearchExpanded = false.obs;

  late ChatRepository _chatRepository;

  @override
  void onInit() {
    super.onInit();
    print('🚀 DrawerSearchController initialized');

    try {
      _chatRepository = Get.find<ChatRepository>();

      // Listen to conversations stream for real-time updates
      _chatRepository.conversationsStream.listen((conversations) {
        print('🔄 Received ${conversations.length} conversations from stream');
        setChats(conversations);
      });

      loadChats();
    } catch (e) {
      print('❌ Error initializing ChatRepository in drawer: $e');
      // Set empty chats to prevent crash
      setChats([]);
    }
  }

  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
  }

  void closeDrawer() {
    isDrawerOpen.value = false;
  }

  void openDrawer() {
    isDrawerOpen.value = true;
    loadChats(); // Refresh chats when drawer opens
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterChats();
  }

  void filterChats() {
    if (searchQuery.value.isEmpty) {
      filteredChats.value = allChats.toList();
    } else {
      filteredChats.value = allChats
          .where((chat) => chat.title
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }
  }

  void setChats(List<Conversation> chats) {
    allChats.value = chats;
    filterChats();
  }

  void clearSearch() {
    searchQuery.value = '';
    filterChats();
  }

  Future<void> loadChats() async {
    try {
      print('🔄 Loading chats...');

      // Check if ChatRepository is available
      if (!Get.isRegistered<ChatRepository>()) {
        print('⚠️ ChatRepository not available, setting empty chats');
        setChats([]);
        return;
      }

      final conversations = await _chatRepository.loadConversations();
      print('📱 Loaded ${conversations.length} conversations');

      // Print details of each conversation for debugging
      for (int i = 0; i < conversations.length; i++) {
        final conv = conversations[i];
        print('📋 Conversation ${i + 1}:');
        print('   ID: ${conv.id}');
        print('   Title: ${conv.title}');
        print('   Smart Title: ${conv.smartTitle}');
        print('   Messages: ${conv.messages.length}');
        print('   Updated: ${conv.updatedAt}');
      }

      // Set chats regardless of whether they're empty or not
      setChats(conversations);
      print('✅ Chats set successfully. Total: ${conversations.length}');
    } catch (e) {
      print('❌ Error loading chats: $e');
      // Set empty list on error
      setChats([]);
    }
  }

  Future<void> renameChat(String chatId, String newTitle) async {
    try {
      await _chatRepository.updateConversationTitle(chatId, newTitle);
      await loadChats(); // Reload chats after rename
    } catch (e) {
      print('Error renaming chat: $e');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _chatRepository.deleteConversation(chatId);
      await loadChats(); // Reload chats after delete
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }

  // Force refresh chats
  Future<void> refreshChats() async {
    print('🔄 Force refreshing chats...');
    try {
      await loadChats();
      print('✅ Chats refreshed successfully');
      print('📱 Current chat count: ${filteredChats.length}');
    } catch (e) {
      print('❌ Error refreshing chats: $e');
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
