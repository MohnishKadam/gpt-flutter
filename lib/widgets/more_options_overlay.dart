import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:chatgpt/screens/model_infor_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MoreOptionsOverlay extends StatelessWidget {
  const MoreOptionsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Material(  // Add this Material widget
      color: Colors.transparent,  // Make it transparent so container color shows
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(top: 60, right: 10),
        decoration: BoxDecoration(
          color: themeController.isDarkMode.value? Colors.grey[900] :Colors.grey[200], 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info_outline, color: themeController.isDarkMode.value?Colors.white : Colors.black),
              title:  Text('View Details', 
                style: TextStyle(color: themeController.isDarkMode.value?Colors.white : Colors.black)),
              onTap: () { 
                Navigator.pop(context);
                Get.to( () => const ModelInfoSheet());
                },
            ),
            ListTile(
              leading:  Icon(Icons.chat_bubble_outline, color:themeController.isDarkMode.value?Colors.white : Colors.black),
              title:  Text('Temporary Chat', 
                style: TextStyle(color: themeController.isDarkMode.value?Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}