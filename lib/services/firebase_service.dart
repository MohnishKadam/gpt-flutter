import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic> mapToChatMessage(Map<String, dynamic> messageData) {
    return {
      'text': messageData['text'],
      'isUser': messageData['isUser'],
      'timestamp': messageData['timestamp'],
      'isLoading': messageData['isLoading'] ?? false,
    };
  }

  Future<String> saveConversation(
      List<Map<String, dynamic>> messages, String title) async {
    try {
      print('🔥 Attempting to save conversation to Firebase...');
      print('📝 Title: $title');
      print('📊 Messages count: ${messages.length}');

      final user = _auth.currentUser;
      if (user == null) {
        print('👤 No authenticated user, attempting anonymous sign-in...');
        try {
          await _auth.signInAnonymously();
          print('✅ Anonymous sign-in successful');
        } catch (signInError) {
          print('❌ Anonymous sign-in failed: $signInError');
          throw Exception('Failed to authenticate user: $signInError');
        }
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ Still no authenticated user after sign-in attempt');
        throw Exception('Failed to authenticate user');
      }

      print('👤 Using user ID: ${currentUser.uid}');

      final docRef = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('conversations')
          .add({
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'messages': messages,
        'messageCount': messages.length,
      });

      print('✅ Conversation saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error saving conversation: $e');
      rethrow;
    }
  }

  Future<void> addMessageToChat(
      String chatId, Map<String, dynamic> message) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .doc(chatId)
          .collection('messages')
          .add({
        ...message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update conversation timestamp
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .doc(chatId)
          .update({
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Message added to chat: $chatId');
    } catch (e) {
      print('❌ Error adding message: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getUserConversations() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ No authenticated user, returning empty stream');
        return Stream.value([]);
      }

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                    'createdAt':
                        doc.data()['createdAt']?.toDate()?.toIso8601String(),
                    'updatedAt':
                        doc.data()['updatedAt']?.toDate()?.toIso8601String(),
                  })
              .toList());
    } catch (e) {
      print('❌ Error getting conversations: $e');
      return Stream.value([]);
    }
  }

  Future<List<Map<String, dynamic>>> getConversationMessages(
      String chatId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
                'timestamp':
                    doc.data()['timestamp']?.toDate()?.toIso8601String(),
              })
          .toList();
    } catch (e) {
      print('❌ Error getting conversation messages: $e');
      return [];
    }
  }

  Future<void> updateConversationTitle(String chatId, String newTitle) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .doc(chatId)
          .update({
        'title': newTitle,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Conversation title updated: $newTitle');
    } catch (e) {
      print('❌ Error updating conversation title: $e');
      rethrow;
    }
  }

  Future<void> deleteConversation(String chatId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Delete all messages in the conversation
      final messagesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .doc(chatId)
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
          .doc(chatId));

      await batch.commit();

      print('✅ Conversation deleted: $chatId');
    } catch (e) {
      print('❌ Error deleting conversation: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();

      print('✅ Message deleted: $messageId');
    } catch (e) {
      print('❌ Error deleting message: $e');
      rethrow;
    }
  }

  Future<void> clearAllConversations() async {
    try {
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
      print('✅ All conversations cleared');
    } catch (e) {
      print('❌ Error clearing conversations: $e');
      rethrow;
    }
  }
}
