import 'dart:typed_data';
import '../llm/llm_provider.dart';
import '../llm/multi_modal_service.dart';
import '../llm/gpt4_service.dart';
import 'task_type.dart';

class CustomTaskAgent {
  final LLMProvider _llmProvider;
  String _selectedModel = 'gpt-4o-mini';

  CustomTaskAgent(this._llmProvider);

  Future<List<String>> getAvailableModels() async {
    final service = _llmProvider.currentService;
    if (service is GPT4Service) {
      await service.testConnection();
    }
    if (service != null) {
      return service.availableModels;
    }
    return [];
  }

  void setModel(String model) {
    final service = _llmProvider.currentService;
    if (service != null) {
      final availableModels = service.availableModels;
      if (!availableModels.contains(model)) {
        throw Exception('不支持的模型: $model');
      }
      service.setCurrentModel(model);
      _selectedModel = model;
    }
  }

  /// 根据任务类型处理输入并返回输出
  Future<String> processTask(TaskType taskType, dynamic input) async {
    final service = _llmProvider.currentService;
    if (service == null) {
      throw Exception('未选择LLM服务');
    }

    // 处理多模态输入
    if (input is Map) {
      if (input.containsKey('text')) {
        if (input.containsKey('audio')) {
          if (!_llmProvider.isFeatureSupported(
            ModalityFeature.textSpeechToText,
          )) {
            throw Exception('当前服务不支持文本+语音处理');
          }
          return await service.textSpeechToText(
            input['text'] as String,
            input['audio'] as Uint8List,
          );
        }
        if (input.containsKey('image')) {
          if (!_llmProvider.isFeatureSupported(
            ModalityFeature.textImageToText,
          )) {
            throw Exception('当前服务不支持文本+图像处理');
          }
          return await service.textImageToText(
            input['text'] as String,
            input['image'] as Uint8List,
          );
        }
      }
    }

    // 处理单一模态输入
    switch (taskType) {
      case TaskType.text:
        if (!_llmProvider.isFeatureSupported(ModalityFeature.textToText)) {
          throw Exception('当前服务不支持文本处理');
        }
        return await service.textToText(input as String);

      case TaskType.image:
        if (!_llmProvider.isFeatureSupported(ModalityFeature.imageToText)) {
          throw Exception('当前服务不支持图片处理');
        }
        return await processImageUnderstanding(input as Uint8List);

      case TaskType.video:
        throw Exception('当前服务不支持视频处理');

      case TaskType.audio:
        if (!_llmProvider.isFeatureSupported(ModalityFeature.speechToText)) {
          throw Exception('当前服务不支持语音处理');
        }
        return await processSpeechToText(input as Uint8List);

      case TaskType.uiUnderstanding:
        throw UnimplementedError('UI理解任务功能尚未实现');

      case TaskType.fileUnderstanding:
        throw UnimplementedError('文件理解任务功能尚未实现');

      case TaskType.sensor:
        throw UnimplementedError('传感器任务功能尚未实现');

      case TaskType.automation:
        throw UnimplementedError('自动执行任务功能尚未实现');
    }
  }

  /// 处理语音输入并返回文本输出
  Future<String> processSpeechToText(Uint8List audioData) async {
    final service = _llmProvider.currentService;
    if (service == null) {
      throw Exception('未选择LLM服务');
    }
    if (!_llmProvider.isFeatureSupported(ModalityFeature.speechToText)) {
      throw Exception('当前服务不支持语音转文本');
    }
    return await service.speechToText(audioData);
  }

  /// 处理文本输入并返回语音输出
  Future<Uint8List> processTextToSpeech(String text) async {
    final service = _llmProvider.currentService;
    if (service == null) {
      throw Exception('未选择LLM服务');
    }
    if (!_llmProvider.isFeatureSupported(ModalityFeature.textToSpeech)) {
      throw Exception('当前服务不支持文本转语音');
    }
    return await service.textToSpeech(text);
  }

  /// 处理图像输入并返回文本描述
  Future<String> processImageUnderstanding(Uint8List imageData) async {
    final service = _llmProvider.currentService;
    if (service == null) {
      throw Exception('未选择LLM服务');
    }
    if (!_llmProvider.isFeatureSupported(ModalityFeature.imageToText)) {
      throw Exception('当前服务不支持图像理解');
    }
    return await service.imageToText(imageData);
  }

  /// 处理文本输入并生成图像
  Future<Uint8List> processImageGeneration(String prompt) async {
    final service = _llmProvider.currentService;
    if (service == null) {
      throw Exception('未选择LLM服务');
    }
    if (!_llmProvider.isFeatureSupported(ModalityFeature.textToImage)) {
      throw Exception('当前服务不支持图像生成');
    }
    return await service.textToImage(prompt);
  }
}
