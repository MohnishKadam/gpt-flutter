import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatgpt/constansts/colors.dart';
import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:chatgpt/controllers/chat_controller.dart';
import 'package:chatgpt/services/storage_service.dart';
import 'package:chatgpt/screens/main_screen.dart';
import 'package:chatgpt/models/conversation.dart';
import 'package:chatgpt/models/message.dart';
import 'package:intl/intl.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final themeController = Get.find<ThemeController>();
  final storageService = Get.find<StorageService>();
  final chatController = Get.find<ChatController>();
  List<Conversation> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      setState(() {
        isLoading = true;
      });

      final loadedConversations = await storageService.loadConversations();
      setState(() {
        conversations = loadedConversations;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading conversations: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(date);
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(date);
      } else {
        return DateFormat('MMM dd').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  String _getPreviewText(Conversation conversation) {
    if (conversation.messages.isEmpty) return 'New conversation';

    // Get the last user message
    final lastUserMessage = conversation.messages
        .where((msg) => msg.role == MessageRole.user)
        .lastOrNull;

    if (lastUserMessage == null) return 'New conversation';

    String text = lastUserMessage.content;
    if (text.length > 50) {
      text = '${text.substring(0, 50)}...';
    }
    return text;
  }

  void _createNewChat() {
    chatController.startNewConversation();
    Get.to(() => MainScreen());
  }

  void _openChat(Conversation conversation) {
    chatController.loadConversation(conversation.id);
    Get.to(() => MainScreen());
  }

  void _deleteConversation(String chatId) async {
    try {
      await storageService.deleteConversation(chatId);
      await _loadConversations(); // Reload the list
      Get.snackbar(
        'Success',
        'Conversation deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete conversation',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _renameConversation(String chatId, String currentTitle) async {
    final TextEditingController textController =
        TextEditingController(text: currentTitle);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, textController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty && newTitle != currentTitle) {
      try {
        await storageService.updateConversationTitle(chatId, newTitle);
        await _loadConversations(); // Reload the list
        Get.snackbar(
          'Success',
          'Conversation renamed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to rename conversation',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.isDarkMode.value
          ? darkmodebackground
          : lightmodebackground,
      appBar: AppBar(
        title: Text(
          'Chat History',
          style: TextStyle(
            color:
                themeController.isDarkMode.value ? darkmodetext : Colors.black,
          ),
        ),
        backgroundColor: themeController.isDarkMode.value
            ? darkmodebackground
            : lightmodebackground,
        iconTheme: IconThemeData(
          color: themeController.isDarkMode.value ? darkmodetext : Colors.black,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewChat,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : conversations.isEmpty
              ? _buildEmptyState()
              : _buildConversationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color:
                themeController.isDarkMode.value ? darkmodetext : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              color:
                  themeController.isDarkMode.value ? darkmodetext : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new chat to begin',
            style: TextStyle(
              color:
                  themeController.isDarkMode.value ? darkmodetext : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createNewChat,
            child: const Text('Start New Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final previewText = _getPreviewText(conversation);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: themeController.isDarkMode.value
                ? darkmodetext
                : Colors.grey[300],
            child: Icon(
              Icons.chat_bubble_outline,
              color: themeController.isDarkMode.value
                  ? darkmodebackground
                  : Colors.grey[700],
            ),
          ),
          title: Text(
            conversation.title,
            style: TextStyle(
              color: themeController.isDarkMode.value
                  ? darkmodetext
                  : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                previewText,
                style: TextStyle(
                  color: themeController.isDarkMode.value
                      ? darkmodetext.withOpacity(0.7)
                      : Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _formatDate(conversation.updatedAt.toIso8601String()),
                style: TextStyle(
                  color: themeController.isDarkMode.value
                      ? darkmodetext.withOpacity(0.5)
                      : Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          onTap: () => _openChat(conversation),
          onLongPress: () =>
              _showConversationOptions(conversation.id, conversation.title),
        );
      },
    );
  }

  void _showConversationOptions(String chatId, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          themeController.isDarkMode.value ? darkmodebackground : Colors.white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _renameConversation(chatId, title);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(chatId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String chatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
            'Are you sure you want to delete this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteConversation(chatId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
