import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class FirebaseTest {
  static final FirebaseService _firebaseService = Get.find<FirebaseService>();
  static final StorageService _storageService = Get.find<StorageService>();

  /// Test Firebase connection and save a sample conversation
  static Future<void> testFirebaseConnection() async {
    print('🧪 Testing Firebase connection...');

    try {
      // Test 1: Save a conversation to Firebase
      print('📝 Creating test conversation...');
      final testConversation = Conversation(
        title: 'Firebase Test Conversation',
        messages: [
          Message(
            content: 'Hello, this is a test message for Firebase',
            role: MessageRole.user,
          ),
          Message(
            content: 'Hi! This is a test response from the AI.',
            role: MessageRole.assistant,
          ),
        ],
      );

      // Save to storage service (which will try Firebase)
      final savedId = await _storageService.saveConversation(testConversation);
      print('✅ Conversation saved with ID: $savedId');

      // Test 2: Load conversations
      print('📱 Loading conversations...');
      final conversations = await _storageService.loadConversations();
      print('✅ Found ${conversations.length} conversations');

      // Test 3: Check if our test conversation is there
      final testConv = conversations.firstWhereOrNull(
          (conv) => conv.title == 'Firebase Test Conversation');

      if (testConv != null) {
        print('✅ Test conversation found in storage');
        print('   ID: ${testConv.id}');
        print('   Title: ${testConv.title}');
        print('   Messages: ${testConv.messages.length}');
      } else {
        print('❌ Test conversation not found in storage');
      }
    } catch (e) {
      print('❌ Firebase test failed: $e');
    }
  }

  /// Test direct Firebase service
  static Future<void> testDirectFirebase() async {
    print('🔥 Testing direct Firebase service...');

    try {
      final testMessages = [
        {
          'text': 'Direct Firebase test message',
          'isUser': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'text': 'Direct Firebase test response',
          'isUser': false,
          'timestamp': DateTime.now().toIso8601String(),
        },
      ];

      final firebaseId = await _firebaseService.saveConversation(
          testMessages, 'Direct Firebase Test');

      print('✅ Direct Firebase save successful: $firebaseId');
    } catch (e) {
      print('❌ Direct Firebase test failed: $e');
    }
  }

  /// Clear all test conversations
  static Future<void> clearTestConversations() async {
    print('🧹 Clearing test conversations...');

    try {
      await _storageService.clearAllConversations();
      print('✅ All conversations cleared');
    } catch (e) {
      print('❌ Error clearing conversations: $e');
    }
  }

  /// Get Firebase status
  static String getFirebaseStatus() {
    try {
      final firebaseService = Get.find<FirebaseService>();
      return 'Firebase service is available';
    } catch (e) {
      return 'Firebase service not available: $e';
    }
  }
}
