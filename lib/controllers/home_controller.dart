import 'dart:io';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final messageText = ''.obs;
  final isExpanded = false.obs;
  final isImageSelected = false.obs;
  final selectedImages = <File>[].obs;
  final canSendMessage = false.obs;
  final showHiddenButtons = false.obs;
  final initialButtonsVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with buttons visible
    initialButtonsVisible.value = true;
    showHiddenButtons.value = false;
  }

  void updateMessageText(String text) {
    messageText.value = text;
    canSendMessage.value = text.trim().isNotEmpty;
  }

  void toggleExpanded() {
    isExpanded.value = !isExpanded.value;
  }

  void addImage(File image) {
    selectedImages.add(image);
    isImageSelected.value = true;
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      if (selectedImages.isEmpty) {
        isImageSelected.value = false;
      }
    }
  }

  void clearImages() {
    selectedImages.clear();
    isImageSelected.value = false;
  }

  void clearMessage() {
    messageText.value = '';
    canSendMessage.value = false;
  }

  void resetState() {
    messageText.value = '';
    isExpanded.value = false;
    isImageSelected.value = false;
    selectedImages.clear();
    canSendMessage.value = false;
  }

  double calculateContainerHeight() {
    // Calculate dynamic height based on content
    // This is a placeholder - you can adjust the logic as needed
    return 200.0; // Default height
  }

  void toggleHiddenButtons() {
    showHiddenButtons.value = !showHiddenButtons.value;
  }

  void showMoreButtons() {
    showHiddenButtons.value = true;
  }

  void hideMoreButtons() {
    showHiddenButtons.value = false;
  }
}
