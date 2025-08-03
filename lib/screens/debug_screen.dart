import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/drawer_search_controller.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../utils/api_test.dart';
import '../utils/rate_limit_helper.dart';
import '../utils/firebase_test.dart';
import '../utils/chat_test.dart';
import '../utils/chat_verification.dart';
import '../utils/debug_drawer.dart';
import '../utils/manual_test.dart';
import '../utils/clear_conversations.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Screen'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Tools',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // API Testing
            _buildSection('API Testing', [
              _buildButton('Test Gemini API', () => ApiTest.testGeminiApi()),
              _buildButton('Get API Status', () {
                final status = ApiTest.getApiStatus();
                print(status);
                Get.snackbar('API Status', status);
              }),
              _buildButton('Reset Rate Limit', () {
                ApiTest.resetRateLimit();
                Get.snackbar('Rate Limit', 'Reset for testing');
              }),
            ]),

            const SizedBox(height: 20),

            // Storage Testing
            _buildSection('Storage Testing', [
              _buildButton('Test Storage Service', () async {
                try {
                  final storageService = Get.find<StorageService>();
                  final conversations =
                      await storageService.loadConversations();
                  print(
                      '📱 Found ${conversations.length} conversations in storage');
                  Get.snackbar('Storage Test',
                      'Found ${conversations.length} conversations');
                } catch (e) {
                  print('❌ Storage test failed: $e');
                  Get.snackbar('Storage Error', e.toString());
                }
              }),
              _buildButton('Clear All Conversations', () async {
                try {
                  final storageService = Get.find<StorageService>();
                  await storageService.clearAllConversations();
                  Get.snackbar('Storage', 'All conversations cleared');
                } catch (e) {
                  Get.snackbar('Error', e.toString());
                }
              }),
            ]),

            const SizedBox(height: 20),

            // Firebase Testing
            _buildSection('Firebase Testing', [
              _buildButton('Test Firebase Connection', () async {
                await FirebaseTest.testFirebaseConnection();
                Get.snackbar('Firebase Test', 'Check console for results');
              }),
              _buildButton('Test Direct Firebase', () async {
                await FirebaseTest.testDirectFirebase();
                Get.snackbar(
                    'Direct Firebase Test', 'Check console for results');
              }),
              _buildButton('Get Firebase Status', () {
                final status = FirebaseTest.getFirebaseStatus();
                print(status);
                Get.snackbar('Firebase Status', status);
              }),
              _buildButton('Clear Test Conversations', () async {
                await FirebaseTest.clearTestConversations();
                Get.snackbar('Firebase', 'Test conversations cleared');
              }),
            ]),

            const SizedBox(height: 20),

            // Chat Controller Testing
            _buildSection('Chat Controller Testing', [
              _buildButton('Test Chat Creation', () async {
                await ChatTest.testChatCreation();
                Get.snackbar('Chat Test', 'Check console for results');
              }),
              _buildButton('Test Send Message', () async {
                await ChatTest.testSendMessage();
                Get.snackbar('Send Message Test', 'Check console for results');
              }),
              _buildButton('Test Drawer Refresh', () async {
                await ChatTest.testDrawerRefresh();
                Get.snackbar(
                    'Drawer Refresh Test', 'Check console for results');
              }),
              _buildButton('Get Chat Status', () {
                final status = ChatTest.getChatStatus();
                print(status);
                Get.snackbar('Chat Status', status);
              }),
              _buildButton('Verify Chat Flow', () async {
                await ChatVerification.verifyChatFlow();
                Get.snackbar('Chat Verification', 'Check console for results');
              }),
              _buildButton('Test Complete Flow', () async {
                await ChatVerification.testCompleteFlow();
                Get.snackbar('Complete Flow Test', 'Check console for results');
              }),
              _buildButton('Debug Drawer State', () async {
                await DebugDrawer.debugDrawerState();
                Get.snackbar('Drawer Debug', 'Check console for results');
              }),
              _buildButton('Force Refresh Drawer', () async {
                await DebugDrawer.forceRefreshDrawer();
                Get.snackbar('Drawer Refresh', 'Check console for results');
              }),
              _buildButton('Create Test Conversation', () async {
                await ManualTest.createTestConversation();
                Get.snackbar('Manual Test', 'Check console for results');
              }),
              _buildButton('Create Multiple Conversations', () async {
                await ManualTest.createMultipleConversations();
                Get.snackbar('Multiple Tests', 'Check console for results');
              }),
              _buildButton('Clear All Conversations', () async {
                await ClearConversations.clearAllConversations();
                Get.snackbar(
                    'Clear All', 'All conversations cleared from sidebar');
              }),
            ]),

            const SizedBox(height: 20),

            // Rate Limit Info
            _buildSection('Rate Limit Information', [
              _buildButton('Get Rate Limit Status', () {
                final status = RateLimitHelper.getCurrentStatus();
                final message = RateLimitHelper.getUserMessage();
                print('Rate Limit Status: $status');
                print('User Message: $message');
                Get.snackbar('Rate Limit', message);
              }),
              _buildButton('Show Rate Limit Tips', () {
                final tips = RateLimitHelper.getRateLimitTips();
                Get.dialog(
                  AlertDialog(
                    title: const Text('Rate Limit Tips'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tips
                          .map((tip) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text('• $tip'),
                              ))
                          .toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text),
      ),
    );
  }
}
