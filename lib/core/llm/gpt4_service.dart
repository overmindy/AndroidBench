import 'dart:typed_data';
import '../network/api_client.dart';
import 'llm_service.dart';
import 'key_manager.dart';

class GPT4Service implements LLMService {
  @override
  String get modelDescription {
    if (_model.isEmpty) {
      return '未选择模型';
    }
    switch (_model) {
      case 'gpt-4':
        return 'GPT-4基础模型，支持高级文本理解和生成';
      case 'gpt-4-32k':
        return 'GPT-4扩展上下文模型，支持更长的对话历史';
      case 'gpt-4-turbo':
        return 'GPT-4优化版本，具有更快的响应速度';
      default:
        return 'GPT-4系列模型';
    }
  }

  final KeyManager _keyManager;
  final ApiClient _apiClient;
  String _model = 'gpt-4o';
  List<String> _availableModels = [];

  GPT4Service._({required KeyManager keyManager})
    : _keyManager = keyManager,
      _apiClient = ApiClient();

  static Future<GPT4Service> getInstance() async {
    final keyManager = await KeyManager.getInstance();
    return GPT4Service._(keyManager: keyManager);
  }

  @override
  Future<String> textCompletion(String prompt) async {
    final apiKey = _keyManager.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API密钥未设置');
    }

    try {
      _apiClient.updateToken(apiKey);
      final response = await _apiClient.post(
        baseUrl,
        data: {
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 401) {
        throw Exception('API密钥无效');
      } else {
        throw Exception('请求失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('调用GPT-4服务失败: $e');
    }
  }

  @override
  Future<String> speechToText(Uint8List audioData) async {
    // TODO: 实现GPT-4的语音转文本功能
    throw UnimplementedError('GPT-4语音转文本功能尚未实现');
  }

  @override
  Future<Uint8List> textToSpeech(String text) async {
    // TODO: 实现GPT-4的文本转语音功能
    throw UnimplementedError('GPT-4文本转语音功能尚未实现');
  }

  @override
  Future<String> imageUnderstanding(Uint8List imageData) async {
    // TODO: 实现GPT-4的图像理解功能
    throw UnimplementedError('GPT-4图像理解功能尚未实现');
  }

  @override
  Future<Uint8List> imageGeneration(String prompt) async {
    // TODO: 实现GPT-4的图像生成功能
    throw UnimplementedError('GPT-4图像生成功能尚未实现');
  }

  void setModel(String model) {
    if (_availableModels.isEmpty) {
      throw Exception('可用模型列表尚未初始化');
    }
    if (!_availableModels.contains(model)) {
      throw Exception('不支持的模型: $model');
    }
    _model = model;
  }

  List<String> getAvailableModels() {
    return List.from(_availableModels);
  }

  String get baseUrl => _keyManager.getBaseUrl();

  @override
  String get serviceName => 'OpenAI';

  @override
  String get serviceDescription => '提供GPT系列模型，支持文本、语音和图像处理功能';

  @override
  List<String> get availableModels => List.unmodifiable(_availableModels);

  @override
  String? get currentModel => _model;

  @override
  void setCurrentModel(String model) => setModel(model);

  @override
  List<LLMFeature> get supportedFeatures => [
    LLMFeature.textCompletion,
    LLMFeature.speechToText,
    LLMFeature.textToSpeech,
    LLMFeature.imageUnderstanding,
    LLMFeature.imageGeneration,
  ];

  Future<bool> testConnection() async {
    final apiKey = _keyManager.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return false;
    }

    try {
      _apiClient.updateToken(apiKey);
      final baseUrl = _keyManager.getBaseUrl();
      // 使用正则表达式提取chat之前的部分
      final match = RegExp(
        r'^(.*?)(?:/v\d+)?/(?:chat|completions)',
      ).firstMatch(baseUrl);
      final modelsUrl =
          match != null ? '${match.group(1)}/v1/models' : '$baseUrl/v1/models';
      final response = await _apiClient.get(modelsUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        _availableModels =
            (data['data'] as List)
                .map((model) => model['id'] as String)
                .where((id) => id.startsWith('gpt-'))
                .toList();

        // 如果当前选择的模型不在可用列表中，选择第一个可用的模型
        if (_availableModels.isNotEmpty && !_availableModels.contains(_model)) {
          _model = _availableModels.first;
        }

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
