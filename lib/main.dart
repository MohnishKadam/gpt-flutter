import 'package:chatgpt/controllers/theme_controller.dart';
import 'package:chatgpt/controllers/chat_controller.dart';
import 'package:chatgpt/controllers/drawer_search_controller.dart';
import 'package:chatgpt/screens/main_screen.dart';
import 'package:chatgpt/services/firebase_service.dart';
import 'package:chatgpt/services/gemini_service.dart';
import 'package:chatgpt/services/auth_service.dart';
import 'package:chatgpt/services/storage_service.dart';
import 'package:chatgpt/services/chat_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_options.dart';

// Import generated Hive adapters
import 'models/message.dart';
import 'models/conversation.dart';
import 'models/ai_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  try {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register adapters
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(MessageRoleAdapter());
    Hive.registerAdapter(ConversationAdapter());
    Hive.registerAdapter(AIModelAdapter());

    print('✅ Hive initialized successfully');
  } catch (e) {
    print('⚠️ Hive initialization failed: $e');
    print('📱 App will continue without local caching');
  }

  // Initialize Firebase with error handling
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
    }
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('📱 App will continue without Firebase features');
  }

  await GetStorage.init();
  Get.put(ThemeController());
  Get.put(GeminiService());
  Get.put(AuthService());

  // Initialize ChatRepository first (manages both local and remote data)
  Get.put(ChatRepository());

  // Initialize StorageService (legacy, will be replaced by ChatRepository)
  Get.put(StorageService());

  // Initialize ChatController after ChatRepository
  Get.put(ChatController());

  // Initialize DrawerSearchController for sidebar functionality
  Get.put(DrawerSearchController());

  // Only initialize FirebaseService if Firebase is available
  try {
    Get.put(FirebaseService());
    print('✅ FirebaseService initialized');
  } catch (e) {
    print('⚠️ FirebaseService initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Obx(
      () => GetMaterialApp(
        theme: themeController.lightTheme,
        darkTheme: themeController.darkTheme,
        themeMode: themeController.currentThemeMode,
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
      ),
    );
  }
}
