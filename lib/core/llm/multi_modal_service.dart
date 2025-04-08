import 'dart:typed_data';

/// 多模态服务接口
/// 定义了一组通用的多模态转换功能，支持文本、语音、图像之间的相互转换
abstract class MultiModalService {
  /// 文本到文本转换
  Future<String> textToText(String text);

  /// 文本到语音转换
  Future<Uint8List> textToSpeech(String text);

  /// 文本到图像转换
  Future<Uint8List> textToImage(String text);

  /// 语音到文本转换
  Future<String> speechToText(Uint8List audioData);

  /// 语音到语音转换
  Future<Uint8List> speechToSpeech(Uint8List audioData);

  /// 图像到文本转换（图像理解）
  Future<String> imageToText(Uint8List imageData);

  /// 文本+图像到文本转换
  Future<String> textImageToText(String text, Uint8List imageData);

  /// 文本+语音到文本转换
  Future<String> textSpeechToText(String text, Uint8List audioData);

  /// 文本+图像到语音转换
  Future<Uint8List> textImageToSpeech(String text, Uint8List imageData);

  /// 文本+语音到语音转换
  Future<Uint8List> textSpeechToSpeech(String text, Uint8List audioData);

  /// 获取服务商名称
  String get serviceName;

  /// 获取服务商描述
  String get serviceDescription;

  /// 获取支持的功能列表
  List<ModalityFeature> get supportedFeatures;

  /// 获取可用的模型列表
  List<String> get availableModels;

  /// 获取当前选择的模型
  String? get currentModel;

  /// 设置当前使用的模型
  void setCurrentModel(String model);

  /// 获取当前模型的描述信息
  String get modelDescription;
}

enum ModalityFeature {
  textToText,
  textToSpeech,
  textToImage,
  speechToText,
  speechToSpeech,
  imageToText,
  textImageToText,
  textSpeechToText,
  textImageToSpeech,
  textSpeechToSpeech,
}
