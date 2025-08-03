import 'package:chatgpt/constansts/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';

class ModelInfoSheet extends StatelessWidget {
  const ModelInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {

    final themeController = Get.find<ThemeController>();
    return Scaffold(
      backgroundColor: themeController.isDarkMode.value ? darkmodebackground : lightmodebackground,
      appBar: AppBar(
        backgroundColor: themeController.isDarkMode.value ? darkmodebackground : lightmodebackground,
        leading:  IconButton(
              icon: Icon(Icons.close, color: themeController.isDarkMode.value ? darkmodetext : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
  ),
      body:  Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           
            const SizedBox(height: 8),
            Image.asset('assets/images/chatgpt_white.png', height: 47),
            const SizedBox(height: 25),
             Text(
              'ChatGPT',
              style: TextStyle(
                color: themeController.isDarkMode.value ? darkmodetext : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Model Info',
                style: TextStyle(
                  color: themeController.isDarkMode.value ? darkmodetext : Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                
                children: [Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Auto',
                    style: TextStyle(color: themeController.isDarkMode.value ? darkmodetext : Colors.black, fontSize: 18),
                  ),
                ),
                 Align(
                  alignment: Alignment.centerLeft,
                   child: Text(
                    'Use the right model for my request',
                    style: TextStyle(color: themeController.isDarkMode.value ? darkmodetext : Colors.black),
                                   ),
                 ),]
              ),
            ),
          ],
        ),
      ),
    );
  }
}