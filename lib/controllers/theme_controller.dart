import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  final isDarkMode = false.obs;
  final themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _loadThemeFromBox();
    themeMode.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  }

  bool _loadThemeFromBox() => _box.read(_key) ?? false;
  ThemeMode get currentThemeMode => themeMode.value;

  void saveTheme(bool isDarkMode) => _box.write(_key, isDarkMode);

  void changeTheme(bool isDarkMode) {
    this.isDarkMode.value = isDarkMode;
    themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
    saveTheme(isDarkMode);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    isDarkMode.value = mode == ThemeMode.dark;
    Get.changeThemeMode(mode);
    saveTheme(isDarkMode.value);
  }

  void toggleTheme() {
    changeTheme(!isDarkMode.value);
  }

  final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  );

  final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  );
}
