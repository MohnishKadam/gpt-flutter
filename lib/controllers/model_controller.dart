import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/ai_model.dart';

class ModelController extends GetxController {
  static const String _modelKey = 'selected_ai_model';
  final _storage = GetStorage();

  final Rx<AIModel> currentModel = AIModel.gemini15Flash.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedModel();
  }

  void _loadSelectedModel() {
    try {
      final modelName = _storage.read<String>(_modelKey);
      if (modelName != null) {
        final model = AIModel.values.firstWhere(
          (model) => model.name == modelName,
          orElse: () => AIModel.gemini15Flash,
        );
        currentModel.value = model;
        print('📱 Loaded selected model: ${model.displayName}');
      } else {
        // Default model
        currentModel.value = AIModel.gemini15Flash;
        _saveSelectedModel(AIModel.gemini15Flash);
      }
    } catch (e) {
      print('❌ Error loading model: $e');
      currentModel.value = AIModel.gemini15Flash;
    }
  }

  void selectModel(AIModel model) {
    currentModel.value = model;
    _saveSelectedModel(model);
    print('🎯 Model changed to: ${model.displayName}');
  }

  void _saveSelectedModel(AIModel model) {
    try {
      _storage.write(_modelKey, model.name);
      print('💾 Saved model selection: ${model.name}');
    } catch (e) {
      print('❌ Error saving model: $e');
    }
  }

  AIModel get selectedModel => currentModel.value;

  String get currentModelName => currentModel.value.displayName;

  String get currentModelApiName => currentModel.value.apiName;

  bool get supportsVision => currentModel.value.supportsVision;

  bool get supportsImages => currentModel.value.supportsImages;
}
