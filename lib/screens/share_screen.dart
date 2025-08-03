import 'package:chatgpt/constansts/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Scaffold(
      backgroundColor: themeController.isDarkMode.value
          ? darkmodebackground
          : lightmodebackground,
      appBar: AppBar(
        backgroundColor: themeController.isDarkMode.value
            ? darkmodebackground
            : lightmodebackground,
        title: Text(
          'Share link to chat',
          style: TextStyle(
              color: themeController.isDarkMode.value
                  ? darkmodetext
                  : Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Messages sent or received after sharing your link won't be shared. "
              "Anyone with the URL will be able to view your shared chat.\n\n"
              "Recipients won’t be able to view your custom profiles.",
              style: TextStyle(
                  fontSize: 16,
                  color: themeController.isDarkMode.value
                      ? darkmodetext
                      : Colors.black),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text("Hi! How can I assist you today?",
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? darkmodetext
                          : Colors.black)),
              subtitle: Text("Show me my previous messages",
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? darkmodetext
                          : Colors.black)),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Implement any additional actions here
                },
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Implement sharing functionality
                },
                icon: const Icon(Icons.share),
                label: Text("Share Link",
                    style: TextStyle(
                        color: themeController.isDarkMode.value
                            ? darkmodetext
                            : Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
