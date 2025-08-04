import 'package:chatgpt/constansts/colors.dart';
import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomizesScreen extends StatelessWidget {
  const CustomizesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeController
    final ThemeController themeController = Get.find();

    return Obx(() => Scaffold(
          backgroundColor: themeController.isDarkMode.value
              ? darkmodebackground
              : lightmodebackground,
          appBar: AppBar(
            backgroundColor: themeController.isDarkMode.value
                ? darkmodebackground
                : lightmodebackground,
            title: Text(
              'Customize',
              style: TextStyle(
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black),
            ),
            leading: BackButton(
              color: themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          body: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  _showThemeDialog(context, themeController);
                },
                child: ListTile(
                  leading: Icon(
                    Icons.tune,
                    color: themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
                  ),
                  title: Text(
                    'Color Scheme',
                    style: TextStyle(
                        color: themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // Show Dialog Box for Theme Options

  void _showThemeDialog(BuildContext context, ThemeController themeController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeController.themeMode.value,
                onChanged: (value) {
                  themeController.setThemeMode(value!);
                  Navigator.of(context).pop();
                },
                title: const Text('System'),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeController.themeMode.value,
                onChanged: (value) {
                  themeController.setThemeMode(value!);
                  Navigator.of(context).pop();
                },
                title: const Text('Light'),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeController.themeMode.value,
                onChanged: (value) {
                  themeController.setThemeMode(value!);
                  Navigator.of(context).pop();
                },
                title: const Text('Dark (Default)'),
              ),
            ],
          ),
        );
      },
    );
  }
}
