import 'package:chatgpt/constansts/colors.dart';
import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:chatgpt/screens/main_screen.dart';
import 'package:chatgpt/services/chat_service.dart';
import 'package:chatgpt/services/firebase_service.dart';

import 'package:chatgpt/widgets/bottom_widget.dart';
import 'package:chatgpt/widgets/chat_message_list.dart';
import 'package:chatgpt/widgets/chat_more_option_overlay.dart';
import 'package:chatgpt/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  final String chatTitle;
  final List<Map<String, dynamic>>? initialMessages;
  final String? conversationId;
  final String? chatId; // Firebase chat ID

  const ChatScreen(
      {super.key,
      required this.chatTitle,
      this.initialMessages,
      this.conversationId,
      this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late List<Map<String, dynamic>> messages;
  late String conversationId;
  final themeController = Get.find<ThemeController>();
  late FirebaseService firebaseService;

  String? currentChatId;

  @override
  void initState() {
    super.initState();

    // Initialize FirebaseService
    try {
      firebaseService = Get.find<FirebaseService>();
    } catch (e) {
      print('⚠️ FirebaseService not available: $e');
      // Create a dummy service to prevent null errors
      firebaseService = FirebaseService();
    }

    // Initialize messages from initial data or default welcome message
    messages = widget.initialMessages ??
        [
          {
            'text': 'Hi! How can I assist you today?',
            'isUser': false,
            'timestamp': DateTime.now().toIso8601String()
          }
        ];
    conversationId = widget.conversationId ??
        DateTime.now().millisecondsSinceEpoch.toString();

    // Set current chat ID
    currentChatId = widget.chatId;
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmit(String text) async {
    if (text.trim().isEmpty) return;

    try {
      // Add user message to messages
      setState(() {
        messages.add({
          'text': text,
          'isUser': true,
          'timestamp': DateTime.now().toIso8601String()
        });
      });

      // Clear text controller
      textController.clear();

      // Add typing indicator
      setState(() {
        messages.add({
          'text': 'Thinking...',
          'isUser': false,
          'timestamp': DateTime.now().toIso8601String(),
          'isLoading': true
        });
      });
      _scrollToBottom();

      // Generate AI response with conversation history (excluding the user message and typing indicator)
      List<Map<String, dynamic>> historyBeforeUserMessage =
          messages.take(messages.length - 2).toList();
      print(
          '📚 ChatScreen: Using ${historyBeforeUserMessage.length} messages as conversation history');

      String aiResponse =
          await ChatService.generateAIResponse(text, historyBeforeUserMessage);

      // Remove typing indicator and add actual AI response
      setState(() {
        messages.removeLast(); // Remove typing indicator
        messages.add({
          'text': aiResponse,
          'isUser': false,
          'timestamp': DateTime.now().toIso8601String(),
          'isLoading': false
        });
      });

      // Save messages to Firebase if we have a chat ID
      if (currentChatId != null) {
        try {
          // Save user message
          final userMessage = firebaseService.mapToChatMessage({
            'text': text,
            'isUser': true,
            'timestamp': DateTime.now().toIso8601String()
          });
          await firebaseService.addMessageToChat(currentChatId!, userMessage);

          // Save AI response
          final aiMessage = firebaseService.mapToChatMessage({
            'text': aiResponse,
            'isUser': false,
            'timestamp': DateTime.now().toIso8601String()
          });
          await firebaseService.addMessageToChat(currentChatId!, aiMessage);

          print('✅ Saved messages to Firebase chat: $currentChatId');
        } catch (e) {
          print('❌ Error saving to Firebase: $e');
          // Continue without Firebase - the messages are already in the UI
        }
      } else {
        // Create new chat in Firebase if this is a new conversation
        try {
          final chatId = await firebaseService.saveConversation(
              messages, widget.chatTitle);
          currentChatId = chatId;
          print('✅ Created new Firebase chat: $chatId');
        } catch (e) {
          print('❌ Error creating Firebase chat: $e');
          // Use a local chat ID if Firebase fails
          currentChatId = DateTime.now().millisecondsSinceEpoch.toString();
        }
      }

      print('✅ Added AI response. Total messages: ${messages.length}');
      _scrollToBottom();

      // Save or update chat
      await ChatService.saveChat(
        conversationId: conversationId,
        messages: messages,
        model: 'gpt-4o-mini',
        title: widget.chatTitle,
      );
    } catch (e) {
      // Show error snackbar
      Get.snackbar(
        'Error',
        'Failed to generate response: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: bottomWidget(
          context,
          onSubmit: _handleSubmit,
          textController: textController,
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: SizedBox(
                    child: themeController.isDarkMode.value
                        ? Image.asset("assets/images/drawer2.png")
                        : Image.asset("assets/images/drawer2.jpg")));
          },
        ),
        iconTheme: IconThemeData(
            color:
                themeController.isDarkMode.value ? darkmodetext : Colors.black),
        backgroundColor: themeController.isDarkMode.value
            ? darkmodebackground
            : lightmodebackground,
        title: Text(widget.chatTitle,
            style: TextStyle(
                color: themeController.isDarkMode.value
                    ? darkmodetext
                    : Colors.black)),
        actions: [
          GestureDetector(
              onTap: () {
                Get.to(() => MainScreen());
              },
              child: themeController.isDarkMode.value
                  ? Image.asset(
                      "assets/images/edit.png",
                      opacity: const AlwaysStoppedAnimation(1),
                      height: 20,
                    )
                  : Image.asset(
                      "assets/images/edit_black.png",
                      opacity: const AlwaysStoppedAnimation(1),
                      height: 20,
                    )),
          IconButton(
            icon: Icon(Icons.more_vert,
                color: themeController.isDarkMode.value
                    ? darkmodetext
                    : Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (context) => Stack(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: LoggerFileOptionsOverlay(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: themeController.isDarkMode.value
          ? darkmodebackground
          : lightmodebackground,
      body: ChatMessageList(messages: messages),
    );
  }
}
