import 'dart:typed_data';

abstract class LLMService {
  /// 文本交互
  Future<String> textCompletion(String prompt);

  /// 语音转文本
  Future<String> speechToText(Uint8List audioData);

  /// 文本转语音
  Future<Uint8List> textToSpeech(String text);

  /// 图像理解
  Future<String> imageUnderstanding(Uint8List imageData);

  /// 图像生成
  Future<Uint8List> imageGeneration(String prompt);

  /// 获取服务商名称
  String get serviceName;

  /// 获取服务商描述
  String get serviceDescription;

  /// 获取支持的功能列表
  List<LLMFeature> get supportedFeatures;

  /// 获取可用的模型列表
  List<String> get availableModels;

  /// 获取当前选择的模型
  String? get currentModel;

  /// 设置当前使用的模型
  void setCurrentModel(String model);

  /// 获取当前模型的描述信息
  String get modelDescription;
}

enum LLMFeature {
  textCompletion,
  speechToText,
  textToSpeech,
  imageUnderstanding,
  imageGeneration,
}
