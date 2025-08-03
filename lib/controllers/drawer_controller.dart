import 'package:get/get.dart';

class AppDrawerController extends GetxController {
  final isDrawerOpen = false.obs;
  final currentIndex = 0.obs;

  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
  }

  void closeDrawer() {
    isDrawerOpen.value = false;
  }

  void openDrawer() {
    isDrawerOpen.value = true;
  }

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }

  void navigateTo(int index) {
    setCurrentIndex(index);
    closeDrawer();
  }
}
