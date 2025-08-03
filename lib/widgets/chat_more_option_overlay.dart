import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:chatgpt/screens/share_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoggerFileOptionsOverlay extends StatelessWidget {
  const LoggerFileOptionsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(top: 60, right: 10),
        decoration: BoxDecoration(
          color: themeController.isDarkMode.value
              ? Colors.grey[900]
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black),
              title: Text('Share',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShareScreen()),
                );
                // Implement share functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.edit,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black),
              title: Text('Rename',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                // Implement rename functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.archive,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black),
              title: Text('Archive',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                // Implement archive functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.delete,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black),
              title: Text('Delete',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Delete Log File"),
                      content: const Text(
                          "Are you sure you want to delete this log file? This action cannot be undone."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            // Implement actual deletion logic here
                            // This might involve:
                            // - Removing the file from storage
                            // - Updating your log file list
                            Navigator.of(context).pop(); // Close the dialog
                            Get.snackbar('Success',
                                'Log file deleted!'); // Show a snackbar
                          },
                          child: const Text("Delete"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.folder,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black),
              title: Text('Move to project',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                // Implement move to project functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black),
              title: Text('View Logs',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                // Implement view logs functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
