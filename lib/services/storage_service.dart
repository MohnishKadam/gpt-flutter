import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'firebase_service.dart';

class StorageService extends GetxService {
  static const String _conversationsKey = 'conversations';
  static const String _lastSyncKey = 'last_sync';

  final GetStorage _storage = GetStorage();
  late FirebaseService _firebaseService;

  // Save conversation to both local storage and Firebase
  Future<String> saveConversation(Conversation conversation) async {
    try {
      print('💾 Starting conversation save process...');
      print('📝 Title: ${conversation.title}');
      print('📊 Messages: ${conversation.messages.length}');

      // Save to local storage first for immediate availability
      await _saveToLocalStorage(conversation);
      print('✅ Saved to local storage');

      // Try to save to Firebase if available
      if (_isFirebaseAvailable()) {
        try {
          print('🔥 Attempting Firebase save...');

          // Convert messages to Firebase format
          final firebaseMessages = conversation.messages
              .map((msg) => {
                    'text': msg.content,
                    'isUser': msg.role == MessageRole.user,
                    'timestamp': msg.timestamp.toIso8601String(),
                    'isLoading': msg.isLoading,
                  })
              .toList();

          final firebaseId = await _firebaseService.saveConversation(
              firebaseMessages, conversation.title);

          // Update local storage with Firebase ID
          final updatedConversation = Conversation(
            id: firebaseId,
            title: conversation.title,
            createdAt: conversation.createdAt,
            updatedAt: DateTime.now(),
            messages: conversation.messages,
            model: conversation.model,
            isPinned: conversation.isPinned,
          );
          await _saveToLocalStorage(updatedConversation);

          print('✅ Conversation saved to both local and Firebase: $firebaseId');
          return firebaseId;
        } catch (e) {
          print('⚠️ Firebase save failed, keeping local only: $e');
          return conversation.id;
        }
      }

      print('✅ Conversation saved to local storage only: ${conversation.id}');
      return conversation.id;
    } catch (e) {
      print('❌ Error saving conversation: $e');
      // Return the conversation ID even if there's an error
      return conversation.id;
    }
  }

  // Load conversations from local storage with Firebase sync
  Future<List<Conversation>> loadConversations() async {
    try {
      print('📂 Loading conversations from local storage...');
      List<Conversation> conversations = await _loadFromLocalStorage();
      print('📱 Found ${conversations.length} conversations in local storage');

      // Try to sync with Firebase if available
      if (_isFirebaseAvailable()) {
        try {
          print('☁️ Syncing with Firebase...');
          final firebaseConversations = await _syncFromFirebase();
          print(
              '☁️ Found ${firebaseConversations.length} conversations in Firebase');
          conversations =
              _mergeConversations(conversations, firebaseConversations);
          await _saveAllToLocalStorage(conversations);
        } catch (e) {
          print('⚠️ Firebase sync failed, using local data: $e');
        }
      }

      // Sort by updatedAt descending
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      print('✅ Returning ${conversations.length} conversations');

      return conversations;
    } catch (e) {
      print('❌ Error loading conversations: $e');
      // Return empty list instead of throwing
      return [];
    }
  }

  // Update conversation title
  Future<void> updateConversationTitle(
      String conversationId, String newTitle) async {
    try {
      final conversations = await _loadFromLocalStorage();
      final index = conversations.indexWhere((c) => c.id == conversationId);

      if (index != -1) {
        final updatedConversation = conversations[index].copyWith(
          title: newTitle,
          updatedAt: DateTime.now(),
        );
        conversations[index] = updatedConversation;
        await _saveAllToLocalStorage(conversations);

        // Try to update Firebase
        if (_isFirebaseAvailable()) {
          try {
            await _firebaseService.updateConversationTitle(
                conversationId, newTitle);
          } catch (e) {
            print('⚠️ Firebase title update failed: $e');
          }
        }
      }
    } catch (e) {
      print('❌ Error updating conversation title: $e');
      rethrow;
    }
  }

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final conversations = await _loadFromLocalStorage();
      conversations.removeWhere((c) => c.id == conversationId);
      await _saveAllToLocalStorage(conversations);

      // Try to delete from Firebase
      if (_isFirebaseAvailable()) {
        try {
          await _firebaseService.deleteConversation(conversationId);
        } catch (e) {
          print('⚠️ Firebase delete failed: $e');
        }
      }
    } catch (e) {
      print('❌ Error deleting conversation: $e');
      rethrow;
    }
  }

  // Add message to conversation
  Future<void> addMessageToConversation(
      String conversationId, Message message) async {
    try {
      final conversations = await _loadFromLocalStorage();
      final index = conversations.indexWhere((c) => c.id == conversationId);

      if (index != -1) {
        final conversation = conversations[index];
        final updatedMessages = List<Message>.from(conversation.messages)
          ..add(message);

        final updatedConversation = conversation.copyWith(
          messages: updatedMessages,
          updatedAt: DateTime.now(),
        );
        conversations[index] = updatedConversation;
        await _saveAllToLocalStorage(conversations);

        // Try to add to Firebase
        if (_isFirebaseAvailable()) {
          try {
            await _firebaseService.addMessageToChat(
                conversationId, message.toJson());
          } catch (e) {
            print('⚠️ Firebase message add failed: $e');
          }
        }
      }
    } catch (e) {
      print('❌ Error adding message to conversation: $e');
      rethrow;
    }
  }

  // Get conversation by ID
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      final conversations = await _loadFromLocalStorage();
      return conversations.firstWhereOrNull((c) => c.id == conversationId);
    } catch (e) {
      print('❌ Error getting conversation: $e');
      return null;
    }
  }

  // Clear all conversations
  Future<void> clearAllConversations() async {
    try {
      await _storage.remove(_conversationsKey);

      if (_isFirebaseAvailable()) {
        try {
          await _firebaseService.clearAllConversations();
        } catch (e) {
          print('⚠️ Firebase clear failed: $e');
        }
      }
    } catch (e) {
      print('❌ Error clearing conversations: $e');
      rethrow;
    }
  }

  // Export conversations to JSON
  Future<String> exportConversations() async {
    try {
      final conversations = await _loadFromLocalStorage();
      final jsonData = conversations.map((c) => c.toJson()).toList();
      return jsonEncode(jsonData);
    } catch (e) {
      print('❌ Error exporting conversations: $e');
      rethrow;
    }
  }

  // Import conversations from JSON
  Future<void> importConversations(String jsonData) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonData);
      final conversations =
          jsonList.map((json) => Conversation.fromJson(json)).toList();
      await _saveAllToLocalStorage(conversations);
    } catch (e) {
      print('❌ Error importing conversations: $e');
      rethrow;
    }
  }

  // Private methods
  bool _isFirebaseAvailable() {
    try {
      if (!Get.isRegistered<FirebaseService>()) {
        print('⚠️ FirebaseService not registered');
        return false;
      }
      _firebaseService = Get.find<FirebaseService>();
      print('✅ FirebaseService found and available');
      return true;
    } catch (e) {
      print('⚠️ FirebaseService not available: $e');
      return false;
    }
  }

  Future<void> _saveToLocalStorage(Conversation conversation) async {
    try {
      final conversations = await _loadFromLocalStorage();
      final index = conversations.indexWhere((c) => c.id == conversation.id);

      if (index != -1) {
        conversations[index] = conversation;
      } else {
        conversations.add(conversation);
      }

      await _saveAllToLocalStorage(conversations);
    } catch (e) {
      print('❌ Error saving to local storage: $e');
      rethrow;
    }
  }

  Future<List<Conversation>> _loadFromLocalStorage() async {
    try {
      final data = _storage.read(_conversationsKey);
      print('📦 Raw data from storage: $data');
      if (data == null) {
        print('📦 No data found in storage');
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(data);
      print('📦 Parsed ${jsonList.length} conversations from JSON');
      return jsonList.map((json) => Conversation.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error loading from local storage: $e');
      return [];
    }
  }

  Future<void> _saveAllToLocalStorage(List<Conversation> conversations) async {
    try {
      final jsonData = conversations.map((c) => c.toJson()).toList();
      await _storage.write(_conversationsKey, jsonEncode(jsonData));
      await _storage.write(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('❌ Error saving all to local storage: $e');
      rethrow;
    }
  }

  Future<List<Conversation>> _syncFromFirebase() async {
    try {
      final firebaseData = await _firebaseService.getUserConversations().first;
      return firebaseData.map((json) => Conversation.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error syncing from Firebase: $e');
      return [];
    }
  }

  List<Conversation> _mergeConversations(
      List<Conversation> local, List<Conversation> firebase) {
    final Map<String, Conversation> merged = {};

    // Add local conversations
    for (final conversation in local) {
      merged[conversation.id] = conversation;
    }

    // Merge with Firebase conversations (Firebase takes precedence for conflicts)
    for (final conversation in firebase) {
      final existing = merged[conversation.id];
      if (existing == null ||
          conversation.updatedAt.isAfter(existing.updatedAt)) {
        merged[conversation.id] = conversation;
      }
    }

    return merged.values.toList();
  }
}
