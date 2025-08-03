import 'package:hive/hive.dart';

part 'ai_model.g.dart';

@HiveType(typeId: 4)
enum AIModel {
  @HiveField(0)
  geminiPro(
      'gemini-1.5-pro', 'Gemini 1.5 Pro', 'Fast and efficient for most tasks'),

  @HiveField(1)
  geminiProVision('gemini-1.5-pro', 'Gemini 1.5 Pro Vision',
      'Can analyze images and text (same as Pro)'),

  @HiveField(2)
  gemini15Flash(
      'gemini-1.5-flash', 'Gemini 1.5 Flash', 'Fast and versatile model'),

  @HiveField(3)
  gemini20Flash(
      'gemini-2.0-flash', 'Gemini 2.0 Flash', 'Newest and most advanced model');

  const AIModel(this.apiName, this.displayName, this.description);

  final String apiName;
  final String displayName;
  final String description;

  bool get supportsVision =>
      this == AIModel.geminiProVision || this == AIModel.geminiPro;

  bool get supportsImages => supportsVision;

  static AIModel fromString(String value) {
    return AIModel.values.firstWhere(
      (model) => model.apiName == value || model.name == value,
      orElse: () => AIModel.gemini15Flash,
    );
  }
}
