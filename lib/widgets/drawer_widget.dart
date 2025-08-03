import 'dart:math';

import 'package:chatgpt/constansts/colors.dart';
import 'package:chatgpt/controllers/drawer_search_controller.dart';
import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:chatgpt/controllers/chat_controller.dart';
import 'package:chatgpt/models/conversation.dart';
import 'package:chatgpt/screens/main_screen.dart';
import 'package:chatgpt/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final themeController = Get.find<ThemeController>();

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  void _showContextMenu(BuildContext context, Conversation chat) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeController.isDarkMode.value
                  ? Colors.grey[850]
                  : lightmodeTextfield,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuItem(
                  context,
                  Icons.edit,
                  'Rename',
                  () {
                    Navigator.pop(context);
                    _showRenameDialog(context, chat);
                  },
                ),
                const Divider(color: Colors.grey, height: 1),
                _buildMenuItem(
                  context,
                  Icons.delete,
                  'Delete',
                  () {
                    Navigator.pop(context);
                    _showDeleteDialog(context, chat);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, Conversation chat) {
    final TextEditingController renameController =
        TextEditingController(text: chat.title);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Rename Chat"),
          content: TextField(
            controller: renameController,
            decoration: const InputDecoration(
              labelText: 'New Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final newTitle = renameController.text.trim();
                if (newTitle.isNotEmpty) {
                  final controller = Get.find<DrawerSearchController>();
                  controller.renameChat(chat.id, newTitle);
                }
                Navigator.of(context).pop();
              },
              child: const Text("Rename"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Conversation chat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Chat"),
          content: Text(
              "Are you sure you want to delete '${chat.title}'? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final controller = Get.find<DrawerSearchController>();
                controller.deleteChat(chat.id);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: themeController.isDarkMode.value
                    ? darkmodetext
                    : Colors.black,
                size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                  color: themeController.isDarkMode.value
                      ? darkmodetext
                      : Colors.black,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(DrawerSearchController controller) {
    return Obx(() {
      final filteredChats = controller.filteredChats;
      print('🎯 Building chat list with ${filteredChats.length} conversations');

      if (filteredChats.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        itemCount: filteredChats.length,
        itemBuilder: (context, index) {
          final chat = filteredChats[index];
          return Dismissible(
            key: Key(chat.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              color: Colors.red,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            confirmDismiss: (direction) async {
              return await _showDeleteConfirmation(context, chat);
            },
            onDismissed: (direction) {
              controller.deleteChat(chat.id);
            },
            child: ChatHistoryTile(
              title: chat.smartTitle,
              subtitle: _formatTimestamp(chat.updatedAt),
              onTap: () {
                _loadConversation(context, chat);
              },
              onLongPress: () => _showContextMenu(context, chat),
            ),
          );
        },
      );
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context, Conversation chat) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Delete Chat"),
              content: Text(
                  "Are you sure you want to delete '${chat.title}'? This action cannot be undone."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _loadConversation(BuildContext context, Conversation conversation) {
    final chatController = Get.find<ChatController>();
    chatController.loadConversation(conversation.id);

    // Navigate to main screen with loaded conversation
    Navigator.pop(context); // Close drawer
    Get.to(() => MainScreen());
  }

  @override
  Widget build(BuildContext context) {
    final DrawerSearchController controller =
        Get.find<DrawerSearchController>();

    // Refresh chats when drawer is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 Drawer built, refreshing chats...');
      controller.refreshChats();
    });

    return Obx(() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: controller.isSearchExpanded.value
            ? MediaQuery.of(context).size.width
            : 304,
        child: Drawer(
          backgroundColor: themeController.isDarkMode.value
              ? const Color(0xFF121212)
              : lightmodebackground,
          child: SafeArea(
            child: Column(
              children: [
                // Search bar with compose button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Search bar container
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              IconButton(
                                icon: Icon(
                                  controller.isSearchExpanded.value
                                      ? Icons.arrow_back
                                      : Icons.search,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  if (controller.isSearchExpanded.value) {
                                    controller.isSearchExpanded.value = false;
                                    controller.searchQuery.value = '';
                                  }
                                },
                              ),
                              Expanded(
                                child: TextField(
                                  style: TextStyle(
                                      color: themeController.isDarkMode.value
                                          ? darkmodetext
                                          : Colors.black),
                                  decoration: InputDecoration(
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    hintText: 'Search',
                                    hintStyle: TextStyle(
                                        color: themeController.isDarkMode.value
                                            ? Colors.grey
                                            : Colors.grey[700]),
                                  ),
                                  onTap: () {
                                    controller.isSearchExpanded.value = true;
                                  },
                                  onChanged: (value) {
                                    controller.searchQuery.value = value;
                                  },
                                ),
                              ),
                              if (!controller.isSearchExpanded.value) ...[],
                            ],
                          ),
                        ),
                      ),
                      // Compose button
                      if (!controller.isSearchExpanded.value) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          icon: themeController.isDarkMode.value
                              ? Image.asset(
                                  "assets/images/edit.png",
                                  opacity: const AlwaysStoppedAnimation(1),
                                  height: 20,
                                )
                              : Image.asset(
                                  "assets/images/edit_black.png",
                                  opacity: const AlwaysStoppedAnimation(1),
                                  height: 20,
                                ),
                          onPressed: () {
                            // Start new conversation
                            final chatController = Get.find<ChatController>();
                            chatController.startNewConversation();
                            Navigator.pop(context); // Close drawer
                            Get.to(() => MainScreen());
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                if (!controller.isSearchExpanded.value) ...[
                  // Your existing drawer content
                  ListTile(
                    leading: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        themeController.isDarkMode.value
                            ? darkmodetext
                            : Colors.black,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        "assets/images/chat-logo.png",
                        width: 24,
                        height: 24,
                      ),
                    ),
                    title: Text(
                      'ChatGPT',
                      style: TextStyle(
                          color: themeController.isDarkMode.value
                              ? darkmodetext
                              : Colors.black,
                          fontSize: 16),
                    ),
                    onTap: () {
                      // Start new conversation when ChatGPT is tapped
                      final chatController = Get.find<ChatController>();
                      chatController.startNewConversation();
                      Navigator.pop(context); // Close drawer
                      Get.to(() => MainScreen());
                    },
                  ),

                  // Library button
                  ListTile(
                    leading: Icon(
                      Icons.photo_library,
                      color: themeController.isDarkMode.value
                          ? darkmodetext
                          : Colors.black,
                    ),
                    title: Text(
                      'Library',
                      style: TextStyle(
                        color: themeController.isDarkMode.value
                            ? darkmodetext
                            : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {},
                  ),

                  // GPTs row
                  ListTile(
                    leading: Icon(
                      Icons.grid_view,
                      color: themeController.isDarkMode.value
                          ? darkmodetext
                          : Colors.black,
                    ),
                    title: Text(
                      'GPTs',
                      style: TextStyle(
                        color: themeController.isDarkMode.value
                            ? darkmodetext
                            : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {},
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(color: Colors.grey),
                  ),
                  // Chats section header
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],

                // Chat list (both for search and normal view)
                Expanded(
                  child: _buildChatList(controller),
                ),

                // Footer profile tile
                if (!controller.isSearchExpanded.value)
                  // ListTile(
                  //   // onTap: () {},
                  //   leading: const CircleAvatar(
                  //     backgroundColor: Colors.purple,
                  //     child: Text('C', style: TextStyle(color: Colors.white)),
                  //   ),
                  //   title: const Text(
                  //     'Mohnish Kadam',
                  //     style: TextStyle(color: Colors.white, fontSize: 14),
                  //   ),
                  //   trailing: IconButton(
                  //     icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  //     onPressed: () {

                  //     },
                  //   ),
                  // ),
                  const DynamicListTile(userName: "Mohnish Kadam")
              ],
            ),
          ),
        ),
      );
    });
  }
}

class DynamicListTile extends StatelessWidget {
  final String userName;

  const DynamicListTile({required this.userName, super.key});

  // Function to generate a random color
  Color _generateRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _generateRandomColor(),
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
          style: TextStyle(
              color: themeController.isDarkMode.value
                  ? darkmodetext
                  : Colors.black),
        ),
      ),
      title: Text(
        userName,
        style: TextStyle(
            color:
                themeController.isDarkMode.value ? darkmodetext : Colors.black,
            fontSize: 14),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz, color: Colors.grey),
        onPressed: () {
          Get.to(() => const SettingsScreen());
        },
      ),
    );
  }
}

class ChatHistoryTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChatHistoryTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      title: Text(
        title,
        style: TextStyle(
          color: themeController.isDarkMode.value ? darkmodetext : Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                subtitle!,
                style: TextStyle(
                  color: themeController.isDarkMode.value
                      ? Colors.grey[400]
                      : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            )
          : null,
      onTap: onTap,
      onLongPress: onLongPress,
      // Add hover effect
      hoverColor: themeController.isDarkMode.value
          ? Colors.grey[800]
          : Colors.grey[200],
    );
  }
}
