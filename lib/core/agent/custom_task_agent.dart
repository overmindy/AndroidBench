import 'dart:typed_data';
import '../llm/llm_provider.dart';
import '../llm/llm_service.dart';
import '../llm/gpt4_service.dart';
import 'task_type.dart';

class CustomTaskAgent {
  final LLMProvider _llmProvider;
  String _selectedModel = 'gpt-4o-mini';

  CustomTaskAgent(this._llmProvider);

  List<String> getAvailableModels() {
    if (_llmProvider.currentService is GPT4Service) {
      return (_llmProvider.currentService as GPT4Service).getAvailableModels();
    }
    return [];
  }

  void setModel(String model) {
    if (_llmProvider.currentService is GPT4Service) {
      final gpt4Service = _llmProvider.currentService as GPT4Service;
      final availableModels = gpt4Service.getAvailableModels();
      if (!availableModels.contains(model)) {
        throw Exception('不支持的模型: $model');
      }
      gpt4Service.setModel(model);
      _selectedModel = model;
    }
  }

  /// 根据任务类型处理输入并返回输出
  Future<String> processTask(TaskType taskType, String input) async {
    final service = _llmProvider.currentService;
    if (service == null) {
      throw Exception('未选择LLM服务');
    }

    switch (taskType) {
      case TaskType.text:
        if (!_llmProvider.isFeatureSupported(LLMFeature.textCompletion)) {
          throw Exception('当前LLM服务不支持文本处理');
        }
        return await service.textCompletion(input);

      case TaskType.image:
        throw UnimplementedError('图片任务功能尚未实现');

      case TaskType.video:
        throw UnimplementedError('视频任务功能尚未实现');

      case TaskType.audio:
        throw UnimplementedError('语音任务功能尚未实现');

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
    if (!_llmProvider.isFeatureSupported(LLMFeature.speechToText)) {
      throw Exception('当前LLM服务不支持语音转文本');
    }
    return await service.speechToText(audioData);
  }

  /// 处理文本输入并返回语音输出
  Future<Uint8List> processTextToSpeech(String text) async {
    final service = _llmProvider.currentService;
    if (service == null) {
      throw Exception('未选择LLM服务');
    }
    if (!_llmProvider.isFeatureSupported(LLMFeature.textToSpeech)) {
      throw Exception('当前LLM服务不支持文本转语音');
    }
    return await service.textToSpeech(text);
  }

  /// 处理图像输入并返回文本描述
  Future<String> processImageUnderstanding(Uint8List imageData) async {
    final service = _llmProvider.currentService;
    if (service == null) {
      throw Exception('未选择LLM服务');
    }
    if (!_llmProvider.isFeatureSupported(LLMFeature.imageUnderstanding)) {
      throw Exception('当前LLM服务不支持图像理解');
    }
    return await service.imageUnderstanding(imageData);
  }

  /// 处理文本输入并生成图像
  Future<Uint8List> processImageGeneration(String prompt) async {
    final service = _llmProvider.currentService;
    if (service == null) {
      throw Exception('未选择LLM服务');
    }
    if (!_llmProvider.isFeatureSupported(LLMFeature.imageGeneration)) {
      throw Exception('当前LLM服务不支持图像生成');
    }
    return await service.imageGeneration(prompt);
  }
}
