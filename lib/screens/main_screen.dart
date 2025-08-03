import 'package:chatgpt/constansts/colors.dart';
import 'package:chatgpt/controllers/drawer_search_controller.dart';
import 'package:chatgpt/controllers/home_controller.dart';
import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:chatgpt/screens/chat_screen.dart';
import 'package:chatgpt/services/chat_service.dart';
import 'package:chatgpt/services/firebase_service.dart';

import 'package:chatgpt/widgets/action_button.dart';
import 'package:chatgpt/widgets/bottom_widget.dart';
import 'package:chatgpt/widgets/drawer_widget.dart';
import 'package:chatgpt/widgets/more_options_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final TextEditingController textController = TextEditingController();
  final themeController = Get.find<ThemeController>();

  void _handleActionButton(String prompt) async {
    print('🎯 Action button pressed with prompt: "$prompt"');

    try {
      // Generate AI response for the action button prompt
      String aiResponse = await ChatService.generateAIResponse(prompt, []);

      // Prepare messages list
      List<Map<String, dynamic>> messages = [
        {
          'text': prompt,
          'isUser': true,
          'timestamp': DateTime.now().toIso8601String()
        },
        {
          'text': aiResponse,
          'isUser': false,
          'timestamp': DateTime.now().toIso8601String()
        }
      ];

      // Save to Firebase and get chat ID
      final firebaseService = Get.find<FirebaseService>();
      final chatId =
          await firebaseService.saveConversation(messages, 'Action Chat');
      print('✅ Saved action chat to Firebase: $chatId');

      // Navigate to ChatScreen with messages and chat ID
      Get.to(() => ChatScreen(
            chatTitle: 'Action Chat',
            initialMessages: messages,
            chatId: chatId,
          ));
    } catch (e) {
      print('❌ Error handling action button: $e');
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
    void handleSubmit(String text) async {
      if (text.trim().isEmpty) return;

      try {
        print('🚀 MainScreen: Starting chat with message: "$text"');

        // Generate AI response with empty conversation history (new chat)
        String aiResponse = await ChatService.generateAIResponse(text, []);

        print(
            '📝 MainScreen: Received AI response: "${aiResponse.substring(0, aiResponse.length > 50 ? 50 : aiResponse.length)}..."');

        // Prepare messages list
        List<Map<String, dynamic>> messages = [
          {
            'text': text,
            'isUser': true,
            'timestamp': DateTime.now().toIso8601String()
          },
          {
            'text': aiResponse,
            'isUser': false,
            'timestamp': DateTime.now().toIso8601String()
          }
        ];

        print(
            '✅ MainScreen: Created message list with ${messages.length} messages');

        // Save to Firebase and get chat ID
        String chatId = '';
        try {
          final firebaseService = Get.find<FirebaseService>();
          chatId = await firebaseService.saveConversation(messages, 'New Chat');
          print('✅ Saved new chat to Firebase: $chatId');
        } catch (e) {
          print('⚠️ Firebase save failed: $e');
          chatId = DateTime.now().millisecondsSinceEpoch.toString();
          print('📱 Using local chat ID: $chatId');
        }

        // Navigate to ChatScreen with messages and chat ID
        Get.to(() => ChatScreen(
              chatTitle: 'New Chat',
              initialMessages: messages,
              chatId: chatId,
            ));

        // Clear text controller
        textController.clear();
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

    final drawerController = Get.put(DrawerSearchController());
    var controller = Get.put(HomeController());
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(children: [
      Transform.scale(
        scale: drawerController.isDrawerOpen.value
            ? 0.3 // Slight scale down when drawer is open
            : 1.0,
        child: Transform.translate(
          offset: Offset(
              drawerController.isDrawerOpen.value
                  ? MediaQuery.of(context).size.width *
                      0.7 // Slide to the right
                  : 0,
              0),
          child: SafeArea(
            child: Scaffold(
              appBar: AppBar(
                forceMaterialTransparency: true,

                leading: Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: SizedBox(
                            child: themeController.isDarkMode.value
                                ? Image.asset(
                                    "assets/images/drawer2.png",
                                  )
                                : Image.asset(
                                    "assets/images/drawer2.jpg",
                                  )));
                  },
                ),
                iconTheme: IconThemeData(
                    color: themeController.isDarkMode.value
                        ? darkmodetext
                        : Colors.black),

                centerTitle: true,
                actions: [
                  GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors
                              .transparent, // Make the barrier transparent
                          builder: (context) => Stack(
                            children: [
                              GestureDetector(
                                // Add this to close dialog when tapping outside
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                              const Positioned(
                                top: 0,
                                right: 0,
                                child: MoreOptionsOverlay(),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(
                        Icons.more_vert,
                        color: themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black,
                      )),
                  const SizedBox(
                    width: 20,
                  )
                ],
                // backgroundColor: themeController.isDarkMode.value ?  : lightmodebackground,
                title: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: Container(
                    width: 100,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8)),
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Text('Get Plus',
                              style: TextStyle(
                                  color: themeController.isDarkMode.value
                                      ? darkmodetext
                                      : Colors.purple)),
                          const SizedBox(
                            width: 5,
                          ),
                          themeController.isDarkMode.value
                              ? const Image(
                                  image: AssetImage("assets/images/star1.png"),
                                  height: 15,
                                )
                              : Image.asset(
                                  "assets/images/star2.png",
                                  height: 15,
                                )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              drawer: const CustomDrawer(),

              drawerEnableOpenDragGesture: true,

              // bottomNavigationBar:  bottomWidget( context, onSubmit: handleSubmit),
              resizeToAvoidBottomInset:
                  true, // Set to false to prevent resizing
              // backgroundColor: themeController.isDarkMode.value ? const Color(0xFF0d0c0c) : lightmodebackground,

              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.18,
                                ),
                                SizedBox(
                                  width: screenWidth * 0.07,
                                ),
                                SizedBox(
                                  width: screenWidth * 0.06,
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(
                                  () => AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOutQuart,
                                    height: (controller.showHiddenButtons.value)
                                        ? 130
                                        : 150,
                                  ),
                                ),
                                Text(
                                  '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: themeController.isDarkMode.value
                                        ? darkmodetext
                                        : Colors.black,
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Obx(
                                  () => AnimatedOpacity(
                                    opacity:
                                        controller.initialButtonsVisible.value
                                            ? 1.0
                                            : 0.0,
                                    duration: const Duration(milliseconds: 800),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        buildActionButton('Create image',
                                            description:
                                                'Generate AI images from text descriptions',
                                            onPressed: () => _handleActionButton(
                                                'Create an AI-generated image based on a detailed description. What kind of image would you like me to help you create?')),
                                        buildActionButton('Brainstorm',
                                            description:
                                                'Get creative ideas and inspiration',
                                            onPressed: () => _handleActionButton(
                                                'I need help brainstorming creative ideas. Can you help me generate some innovative concepts and inspiration?')),
                                        buildActionButton('Make a plan',
                                            description:
                                                'Create structured plans and outlines',
                                            onPressed: () => _handleActionButton(
                                                'I need help creating a structured plan. Can you help me organize my thoughts and create a detailed outline?')),
                                        Obx(
                                          () => Visibility(
                                            visible: !controller
                                                .showHiddenButtons.value,
                                            child: buildActionButton('More',
                                                description:
                                                    'Show additional options',
                                                onPressed: () {
                                              controller.showHiddenButtons
                                                  .value = true;
                                            }),
                                          ),
                                        ),
                                        Obx(
                                          () => AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 800),
                                            curve: Curves.easeInOutQuart,
                                            height: controller
                                                    .showHiddenButtons.value
                                                ? controller
                                                    .calculateContainerHeight() // Dynamic height calculation
                                                : 0,
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: const BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            child: SingleChildScrollView(
                                              child: Visibility(
                                                visible: controller
                                                    .showHiddenButtons.value,
                                                child: Column(
                                                  children: [
                                                    Wrap(
                                                      alignment:
                                                          WrapAlignment.center,
                                                      spacing: 16,
                                                      runSpacing: 16,
                                                      children: [
                                                        buildActionButton(
                                                            'Get advice',
                                                            description:
                                                                'Receive guidance and recommendations',
                                                            onPressed: () =>
                                                                _handleActionButton(
                                                                    'I need advice and guidance. Can you provide me with helpful recommendations and suggestions?')),
                                                        buildActionButton(
                                                            'Summarise text',
                                                            description:
                                                                'Create concise summaries from long content',
                                                            onPressed: () =>
                                                                _handleActionButton(
                                                                    'I need help summarizing text content. Can you help me create concise summaries from long documents or articles?')),
                                                        buildActionButton(
                                                            'Surprise me',
                                                            description:
                                                                'Get random interesting prompts',
                                                            onPressed: () =>
                                                                _handleActionButton(
                                                                    'Surprise me with an interesting and creative prompt or idea that I can explore!')),
                                                        buildActionButton(
                                                            'Analyze image',
                                                            description:
                                                                'Understand and describe image content',
                                                            onPressed: () =>
                                                                _handleActionButton(
                                                                    'I need help analyzing and understanding image content. Can you help me describe and interpret images?')),
                                                        buildActionButton(
                                                            'Code',
                                                            description:
                                                                'Programming help and code generation',
                                                            onPressed: () =>
                                                                _handleActionButton(
                                                                    'I need help with programming and code generation. Can you assist me with coding tasks and technical solutions?')),
                                                        buildActionButton(
                                                            'Analyze data',
                                                            description:
                                                                'Extract insights from datasets',
                                                            onPressed: () =>
                                                                _handleActionButton(
                                                                    'I need help analyzing data and extracting insights from datasets. Can you help me understand and interpret data?')),
                                                        buildActionButton(
                                                            'Help me write',
                                                            description:
                                                                'Assist with writing and editing',
                                                            onPressed: () =>
                                                                _handleActionButton(
                                                                    'I need help with writing and editing. Can you assist me with improving my writing skills and content creation?')),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.15),
                          ],
                        ),
                      ),
                    ),
                    bottomWidget(context,
                        onSubmit: handleSubmit,
                        textController: textController // Pass text controller
                        ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
      if (drawerController.isDrawerOpen.value)
        GestureDetector(
          onTap: () {
            drawerController.isDrawerOpen.value = false;
          },
          child: Container(
            color: themeController.isDarkMode.value
                ? darkmodebackground
                : lightmodebackground,
          ),
        ),
    ]);
  }
}
