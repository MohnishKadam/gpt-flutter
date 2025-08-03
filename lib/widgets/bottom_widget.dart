import 'dart:io';

import 'package:chatgpt/constansts/colors.dart';
import 'package:chatgpt/controllers/home_controller.dart';
import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

var controller = Get.put(HomeController());
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
    () => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image previews

        // Message input field
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: themeController.isDarkMode.value
                ? darkmodebackground
                : lightmodebackground,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // New circular button design
              GestureDetector(
                onTap: () {
                  // Show options menu or perform action
                  showOptionsMenu(context, pickImage);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: themeController.isDarkMode.value
                        ? Colors.black87
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black,
                      size: 28,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              // Resizable text field
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: controller.selectedImages.isNotEmpty ? 250 : 100,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (controller.selectedImages.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 90,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.selectedImages.length,
                                  itemBuilder: (context, index) {
                                    final imageFile =
                                        controller.selectedImages[index];
                                    return Stack(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.file(
                                              imageFile,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              controller.selectedImages
                                                  .removeAt(index);
                                            },
                                            child: CircleAvatar(
                                              radius: 10,
                                              backgroundColor: themeController
                                                      .isDarkMode.value
                                                  ? darkmodetext
                                                  : Colors.black,
                                              child: Icon(Icons.close,
                                                  color: themeController
                                                          .isDarkMode.value
                                                      ? Colors.black
                                                      : Colors.white,
                                                  size: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              style: TextStyle(
                                  color: themeController.isDarkMode.value
                                      ? darkmodetext
                                      : Colors.black),
                              controller: textController,
                              onChanged: (value) {
                                if (value.isNotEmpty &&
                                    !controller.isExpanded.value) {
                                  controller.isExpanded.value = true;
                                }
                              },
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.mic_rounded,
                                    color: themeController.isDarkMode.value
                                        ? darkmodetext
                                        : Colors.black),
                                hintText: "Ask anything",
                                hintStyle: TextStyle(
                                    color: themeController.isDarkMode.value
                                        ? darkmodetext
                                        : Colors.black),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              GestureDetector(
                onTap: () {
                  if (controller.canSendMessage.value) {
                    // Send message logic
                    String text = localTextController.text.trim();
                    if (text.isNotEmpty) {
                      print('🚀 Send button pressed with text: "$text"');
                      onSubmit(
                          text); // Call the onSubmit function passed from main_screen

                      // Reset states after sending
                      localTextController.clear();
                      controller.messageText.value = '';
                      controller.isImageSelected.value = false;
                    }
                  } else {
                    // Voice recording logic
                    // Implement your voice recording functionality
                  }
                },
                child: CircleAvatar(
                  backgroundColor: themeController.isDarkMode.value
                      ? darkmodetext
                      : Colors.black,
                  radius: 20,
                  child: controller.canSendMessage.value
                      ? Icon(Icons.arrow_upward_outlined,
                          color: themeController.isDarkMode.value
                              ? Colors.black
                              : Colors.white) // Send icon
                      : (themeController.isDarkMode.value
                          ? Image.asset("assets/images/voice.png", height: 30)
                          : Image.asset("assets/images/voice-white.png",
                              height: 30)),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
            ],
          ),
        ),
      ],
    ),
  );
}
