import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/ai_model.dart';

class ChatRepository extends GetxService {
  static const String _conversationsBoxName = 'conversations';
  static const String _syncStatusBoxName = 'sync_status';

  late Box<Conversation> _conversationsBox;
  late Box<String> _syncStatusBox;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controllers for real-time updates
  final _conversationsController =
      StreamController<List<Conversation>>.broadcast();
  final _syncStatusController = StreamController<bool>.broadcast();

  // Observable properties
  final RxBool isOnline = true.obs;
  final RxBool isSyncing = false.obs;
  final RxString currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeHive();
    _setupAuthListener();
  }

  @override
  void onClose() {
    _conversationsController.close();
    _syncStatusController.close();
    super.onClose();
  }

  // Initialize Hive boxes
  Future<void> _initializeHive() async {
    try {
      _conversationsBox =
          await Hive.openBox<Conversation>(_conversationsBoxName);
      _syncStatusBox = await Hive.openBox<String>(_syncStatusBoxName);
      print('✅ Hive boxes initialized successfully');
    } catch (e) {
      print('❌ Error initializing Hive: $e');
      rethrow;
    }
  }

  // Setup Firebase Auth listener
  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        currentUserId.value = user.uid;
        print('👤 User authenticated: ${user.uid}');
        _syncData();
      } else {
        currentUserId.value = '';
        print('👤 User signed out');
      }
    });
  }

  // Get conversations stream
  Stream<List<Conversation>> get conversationsStream =>
      _conversationsController.stream;

  // Get sync status stream
  Stream<bool> get syncStatusStream => _syncStatusController.stream;

  // Save conversation (both local and remote)
  Future<String> saveConversation(Conversation conversation) async {
    try {
      print('💾 Saving conversation: ${conversation.title}');

      // Save to local storage first for immediate availability
      await _saveToLocalStorage(conversation);

      // Try to save to Firebase if user is authenticated
      if (currentUserId.value.isNotEmpty) {
        try {
          final firebaseId = await _saveToFirebase(conversation);

          // Update local conversation with Firebase ID
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
          _notifyConversationsChanged();
          return firebaseId;
        } catch (e) {
          print('⚠️ Firebase save failed, keeping local only: $e');
          _markForSync(conversation.id);
        }
      }

      print('✅ Conversation saved to local storage: ${conversation.id}');
      _notifyConversationsChanged();
      return conversation.id;
    } catch (e) {
      print('❌ Error saving conversation: $e');
      rethrow;
    }
  }

  // Load conversations from local storage
  Future<List<Conversation>> loadConversations() async {
    try {
      final conversations = _conversationsBox.values.toList();
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      print(
          '📂 Loaded ${conversations.length} conversations from local storage');
      _notifyConversationsChanged();
      return conversations;
    } catch (e) {
      print('❌ Error loading conversations: $e');
      return [];
    }
  }

  // Add message to conversation
  Future<void> addMessageToConversation(
      String conversationId, Message message) async {
    try {
      final conversation = _conversationsBox.get(conversationId);
      if (conversation == null) {
        throw Exception('Conversation not found: $conversationId');
      }

      final updatedMessages = List<Message>.from(conversation.messages)
        ..add(message);
      final updatedConversation = conversation.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );

      await _saveToLocalStorage(updatedConversation);

      // Try to sync with Firebase
      if (currentUserId.value.isNotEmpty) {
        try {
          await _addMessageToFirebase(conversationId, message);
        } catch (e) {
          print('⚠️ Firebase message sync failed: $e');
          _markForSync(conversationId);
        }
      }

      _notifyConversationsChanged();
    } catch (e) {
      print('❌ Error adding message: $e');
      rethrow;
    }
  }

  // Update conversation title
  Future<void> updateConversationTitle(
      String conversationId, String newTitle) async {
    try {
      final conversation = _conversationsBox.get(conversationId);
      if (conversation == null) {
        throw Exception('Conversation not found: $conversationId');
      }

      final updatedConversation = conversation.copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );

      await _saveToLocalStorage(updatedConversation);

      // Try to sync with Firebase
      if (currentUserId.value.isNotEmpty) {
        try {
          await _updateConversationTitleInFirebase(conversationId, newTitle);
        } catch (e) {
          print('⚠️ Firebase title update failed: $e');
          _markForSync(conversationId);
        }
      }

      _notifyConversationsChanged();
    } catch (e) {
      print('❌ Error updating conversation title: $e');
      rethrow;
    }
  }

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _conversationsBox.delete(conversationId);

      // Try to delete from Firebase
      if (currentUserId.value.isNotEmpty) {
        try {
          await _deleteConversationFromFirebase(conversationId);
        } catch (e) {
          print('⚠️ Firebase delete failed: $e');
          _markForSync(conversationId);
        }
      }

      _notifyConversationsChanged();
    } catch (e) {
      print('❌ Error deleting conversation: $e');
      rethrow;
    }
  }

  // Get conversation by ID
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      return _conversationsBox.get(conversationId);
    } catch (e) {
      print('❌ Error getting conversation: $e');
      return null;
    }
  }

  // Clear all conversations
  Future<void> clearAllConversations() async {
    try {
      await _conversationsBox.clear();

      // Try to clear from Firebase
      if (currentUserId.value.isNotEmpty) {
        try {
          await _clearAllConversationsFromFirebase();
        } catch (e) {
          print('⚠️ Firebase clear failed: $e');
        }
      }

      _notifyConversationsChanged();
    } catch (e) {
      print('❌ Error clearing conversations: $e');
      rethrow;
    }
  }

  // Sync data with Firebase
  Future<void> _syncData() async {
    if (currentUserId.value.isEmpty) return;

    try {
      isSyncing.value = true;
      _syncStatusController.add(true);

      // Get conversations from Firebase
      final firebaseConversations = await _loadFromFirebase();

      // Merge with local conversations
      final mergedConversations = _mergeConversations(
        _conversationsBox.values.toList(),
        firebaseConversations,
      );

      // Save merged conversations to local storage
      for (final conversation in mergedConversations) {
        await _saveToLocalStorage(conversation);
      }

      _notifyConversationsChanged();
      print('✅ Data synced successfully');
    } catch (e) {
      print('❌ Error syncing data: $e');
    } finally {
      isSyncing.value = false;
      _syncStatusController.add(false);
    }
  }

  // Private helper methods

  Future<void> _saveToLocalStorage(Conversation conversation) async {
    await _conversationsBox.put(conversation.id, conversation);
  }

  Future<String> _saveToFirebase(Conversation conversation) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final firebaseMessages = conversation.messages
        .map((msg) => {
              'text': msg.content,
              'isUser': msg.role == MessageRole.user,
              'timestamp': msg.timestamp.toIso8601String(),
              'isLoading': msg.isLoading,
            })
        .toList();

    final docRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .add({
      'title': conversation.title,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'messages': firebaseMessages,
      'messageCount': firebaseMessages.length,
      'model': conversation.model.name,
      'isPinned': conversation.isPinned,
    });

    return docRef.id;
  }

  Future<void> _addMessageToFirebase(
      String conversationId, Message message) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
      'text': message.content,
      'isUser': message.role == MessageRole.user,
      'timestamp': FieldValue.serverTimestamp(),
      'isLoading': message.isLoading,
    });

    // Update conversation timestamp
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .doc(conversationId)
        .update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateConversationTitleInFirebase(
      String conversationId, String newTitle) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .doc(conversationId)
        .update({
      'title': newTitle,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteConversationFromFirebase(String conversationId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Delete all messages in the conversation
    final messagesSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the conversation document
    batch.delete(_firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .doc(conversationId));

    await batch.commit();
  }

  Future<void> _clearAllConversationsFromFirebase() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final conversationsSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations')
        .get();

    final batch = _firestore.batch();

    for (final convDoc in conversationsSnapshot.docs) {
      // Delete all messages in each conversation
      final messagesSnapshot =
          await convDoc.reference.collection('messages').get();
      for (final msgDoc in messagesSnapshot.docs) {
        batch.delete(msgDoc.reference);
      }
      // Delete the conversation
      batch.delete(convDoc.reference);
    }

    await batch.commit();
  }

  Future<List<Conversation>> _loadFromFirebase() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Conversation(
          id: doc.id,
          title: data['title'] ?? 'Untitled',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt:
              (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          messages: [], // Messages are stored separately in Firebase
          model: AIModel.fromString(data['model'] ?? 'gemini-1.5-flash'),
          isPinned: data['isPinned'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('❌ Error loading from Firebase: $e');
      return [];
    }
  }

  List<Conversation> _mergeConversations(
    List<Conversation> local,
    List<Conversation> firebase,
  ) {
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

  void _markForSync(String conversationId) {
    // Mark conversation for sync when online
    _syncStatusBox.put(
        'pending_sync_$conversationId', DateTime.now().toIso8601String());
  }

  void _notifyConversationsChanged() {
    final conversations = _conversationsBox.values.toList();
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _conversationsController.add(conversations);
  }

  // Manual sync method
  Future<void> syncData() async {
    await _syncData();
  }
}
