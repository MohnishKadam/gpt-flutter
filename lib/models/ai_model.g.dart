// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AIModelAdapter extends TypeAdapter<AIModel> {
  @override
  final int typeId = 4;

  @override
  AIModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AIModel.geminiPro;
      case 1:
        return AIModel.geminiProVision;
      case 2:
        return AIModel.gemini15Flash;
      case 3:
        return AIModel.gemini20Flash;
      default:
        return AIModel.geminiPro;
    }
  }

  @override
  void write(BinaryWriter writer, AIModel obj) {
    switch (obj) {
      case AIModel.geminiPro:
        writer.writeByte(0);
        break;
      case AIModel.geminiProVision:
        writer.writeByte(1);
        break;
      case AIModel.gemini15Flash:
        writer.writeByte(2);
        break;
      case AIModel.gemini20Flash:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
