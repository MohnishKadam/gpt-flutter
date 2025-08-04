import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ai_model.dart';
import '../controllers/theme_controller.dart';
import '../controllers/model_controller.dart';
import '../constansts/colors.dart';

class ModelSelectionScreen extends StatelessWidget {
  const ModelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: themeController.isDarkMode.value
          ? darkmodebackground
          : lightmodebackground,
      appBar: AppBar(
        title: Text(
          'Select AI Model',
          style: TextStyle(
            color:
                themeController.isDarkMode.value ? darkmodetext : Colors.black,
          ),
        ),
        backgroundColor: themeController.isDarkMode.value
            ? darkmodebackground
            : lightmodebackground,
        iconTheme: IconThemeData(
          color: themeController.isDarkMode.value ? darkmodetext : Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your preferred AI model:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeController.isDarkMode.value
                    ? darkmodetext
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: AIModel.values.length,
                itemBuilder: (context, index) {
                  final model = AIModel.values[index];
                  return _buildModelCard(context, model, themeController);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard(
      BuildContext context, AIModel model, ThemeController themeController) {
    final isSelected = _isCurrentModel(model);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: themeController.isDarkMode.value ? Colors.grey[850] : Colors.white,
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(
                color: Colors.blue,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _selectModel(context, model),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeController.isDarkMode.value
                                ? darkmodetext
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          model.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: themeController.isDarkMode.value
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (model.supportsVision)
                    _buildFeatureChip('Vision', Icons.image, themeController),
                  const SizedBox(width: 8),
                  if (model.supportsImages)
                    _buildFeatureChip('Images', Icons.photo, themeController),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(
      String label, IconData icon, ThemeController themeController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentModel(AIModel model) {
    final modelController = Get.find<ModelController>();
    return modelController.selectedModel == model;
  }

  void _selectModel(BuildContext context, AIModel model) {
    final modelController = Get.find<ModelController>();
    modelController.selectModel(model);

    // Show confirmation
    Get.snackbar(
      'Model Selected',
      'Switched to ${model.displayName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Navigate back
    Navigator.pop(context);
  }
}
