import 'dart:typed_data';
import 'llm_service.dart';

class DeepseekService implements LLMService {
  @override
  String get modelDescription {
    if (_currentModel == null) {
      return '未选择模型';
    }
    switch (_currentModel) {
      case 'deepseek-chat-1.3b':
        return '轻量级对话模型，适合简单的对话任务';
      case 'deepseek-coder-6.7b':
        return '专门用于代码生成和理解的模型';
      case 'deepseek-moe-16b':
        return '大规模混合专家模型，适合复杂的多领域任务';
      default:
        return '未知模型';
    }
  }

  @override
  Future<String> textCompletion(String prompt) async {
    // TODO: 实现Deepseek的文本补全功能
    throw UnimplementedError('Deepseek文本补全功能尚未实现');
  }

  @override
  Future<String> speechToText(Uint8List audioData) async {
    // TODO: 实现Deepseek的语音转文本功能
    throw UnimplementedError('Deepseek语音转文本功能尚未实现');
  }

  @override
  Future<Uint8List> textToSpeech(String text) async {
    // TODO: 实现Deepseek的文本转语音功能
    throw UnimplementedError('Deepseek文本转语音功能尚未实现');
  }

  @override
  Future<String> imageUnderstanding(Uint8List imageData) async {
    // TODO: 实现Deepseek的图像理解功能
    throw UnimplementedError('Deepseek图像理解功能尚未实现');
  }

  @override
  Future<Uint8List> imageGeneration(String prompt) async {
    // TODO: 实现Deepseek的图像生成功能
    throw UnimplementedError('Deepseek图像生成功能尚未实现');
  }

  String? _currentModel;
  final List<String> _availableModels = [
    'deepseek-chat-1.3b',
    'deepseek-coder-6.7b',
    'deepseek-moe-16b',
  ];

  @override
  String get serviceName => 'Deepseek';

  @override
  String get serviceDescription => 'Deepseek大语言模型，支持文本、语音和图像处理功能';

  @override
  List<LLMFeature> get supportedFeatures => [
    LLMFeature.textCompletion,
    LLMFeature.speechToText,
    LLMFeature.textToSpeech,
    LLMFeature.imageUnderstanding,
    LLMFeature.imageGeneration,
  ];

  @override
  List<String> get availableModels => _availableModels;

  @override
  String? get currentModel => _currentModel;

  @override
  void setCurrentModel(String model) {
    if (_availableModels.contains(model)) {
      _currentModel = model;
    } else {
      throw ArgumentError('不支持的模型：$model');
    }
  }
}
