import 'package:chatgpt/constansts/colors.dart';
import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:chatgpt/screens/customize_screen.dart';
import 'package:chatgpt/services/auth_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => Scaffold(
          backgroundColor: themeController.isDarkMode.value
              ? darkmodebackground
              : lightmodebackground,
          appBar: AppBar(
            backgroundColor: themeController.isDarkMode.value
                ? darkmodebackground
                : lightmodebackground,
            title: Text('Settings',
                style: TextStyle(
                    color: themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black)),
            leading: BackButton(
              color: themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text('MK', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mohnish Kadam',
                          style: TextStyle(
                              color: themeController.isDarkMode.value
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'mohnish2k2@gmail.com',
                          style: TextStyle(
                              color: themeController.isDarkMode.value
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.email,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text(
                  'Email',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black),
                ),
                subtitle: Text(
                  'mohnish2k2@gmail.com',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.phone,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text(
                  'Phone number',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black),
                ),
                subtitle: Text(
                  '+918435229068',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.upgrade,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text(
                  'Upgrade to Plus',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black),
                ),
                trailing: ElevatedButton(
                  child: Text(
                    'Upgrade',
                    style: TextStyle(
                        color: themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black),
                  ),
                  onPressed: () {
                    // Upgrade logic here
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => const CustomizesScreen());
                },
                child: ListTile(
                  leading: Icon(
                    Icons.tune,
                    color: themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
                  ),
                  title: Text(
                    'Customize',
                    style: TextStyle(
                        color: themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.data_usage,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text(
                  'Data Controls',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.volume_up,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text(
                  'Voice',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text(
                  'About',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text(
                  'Sign out',
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black),
                ),
                onTap: () {
                  // Add sign out logic here
                  final authService = Get.find<AuthService>();
                  authService.signOut();
                },
              ),
            ],
          ),
        ));
  }
}
