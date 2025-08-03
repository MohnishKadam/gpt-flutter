import 'package:chatgpt/constansts/colors.dart';
import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildActionButton(String text,
    {Widget? icon,
    String? description,
    required VoidCallback onPressed,
    bool isMoreButton = false}) {
  final themeController = Get.find<ThemeController>();

  return Container(
    decoration: BoxDecoration(
      color: themeController.isDarkMode.value
          ? Colors.grey[850]
          : Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: themeController.isDarkMode.value
            ? Colors.grey[700]!
            : Colors.grey[300]!,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: description != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? darkmodetext
                          : lightmodetext,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                        color: themeController.isDarkMode.value
                            ? darkmodetext
                            : lightmodetext,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
      ),
    ),
  );
}
