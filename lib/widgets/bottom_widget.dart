import 'dart:io';

import 'package:chatgpt/constansts/colors.dart';
import 'package:chatgpt/controllers/home_controller.dart';
import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

var controller = Get.find<HomeController>();
var screenWidth = Get.context!.width;
double iconSize = screenWidth * 0.07;

Widget bottomWidget(BuildContext context,
    {required Function(String) onSubmit,
    TextEditingController? textController}) {
  final TextEditingController localTextController =
      textController ?? TextEditingController();
  final themeController = Get.find<ThemeController>();

  localTextController.addListener(() {
    controller.updateMessageText(localTextController.text);
  });

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images =
        await picker.pickMultiImage(); // Multi-image picker
    if (images.isNotEmpty) {
      controller.selectedImages.addAll(images.map((image) => File(image.path)));
    }
  }

  void showOptionsMenu(BuildContext context, Function(ImageSource) pickImage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color:
                themeController.isDarkMode.value ? Colors.black : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.image_outlined,
                    color: themeController.isDarkMode.value
                        ? darkmodetext
                        : Colors.black),
                title: Text('Gallery',
                    style: TextStyle(
                        color: themeController.isDarkMode.value
                            ? darkmodetext
                            : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined,
                    color: themeController.isDarkMode.value
                        ? darkmodetext
                        : Colors.black),
                title: Text('Camera',
                    style: TextStyle(
                        color: themeController.isDarkMode.value
                            ? darkmodetext
                            : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.folder_outlined,
                    color: themeController.isDarkMode.value
                        ? darkmodetext
                        : Colors.black),
                title: Text('Files',
                    style: TextStyle(
                        color: themeController.isDarkMode.value
                            ? darkmodetext
                            : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  // Add file picker functionality
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  return Obx(
    () => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Left Attachment Button (+)
          GestureDetector(
            onTap: () {
              showOptionsMenu(context, pickImage);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: themeController.isDarkMode.value
                    ? Colors.grey[850]
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Center Text Field Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeController.isDarkMode.value
                    ? Colors.grey[850]
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: localTextController,
                style: TextStyle(
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: "Ask anything",
                  hintStyle: TextStyle(
                    color: themeController.isDarkMode.value
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Microphone Icon
                      IconButton(
                        onPressed: () {
                          // Voice recording functionality
                          print('🎤 Voice recording pressed');
                        },
                        icon: Icon(
                          Icons.mic_rounded,
                          color: themeController.isDarkMode.value
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send Button (Equalizer/Sound-wave icon)
                      GestureDetector(
                        onTap: () {
                          if (localTextController.text.trim().isNotEmpty) {
                            String text = localTextController.text.trim();
                            print('🚀 Send button pressed with text: "$text"');
                            onSubmit(text);
                            localTextController.clear();
                            controller.messageText.value = '';
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                controller.messageText.value.trim().isNotEmpty
                                    ? (themeController.isDarkMode.value
                                        ? Colors.white
                                        : Colors.black)
                                    : Colors.grey[600],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              controller.messageText.value.trim().isNotEmpty
                                  ? Icons
                                      .arrow_upward_rounded // Upward arrow when text is present
                                  : Icons
                                      .graphic_eq_rounded, // Equalizer when empty
                              color:
                                  controller.messageText.value.trim().isNotEmpty
                                      ? (themeController.isDarkMode.value
                                          ? Colors.black
                                          : Colors.white)
                                      : Colors.grey[400],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
                onChanged: (value) {
                  controller.updateMessageText(value);
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
