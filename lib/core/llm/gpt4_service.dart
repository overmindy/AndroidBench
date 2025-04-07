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
    final service = GPT4Service._(keyManager: keyManager);
    // 异步加载模型列表
    service._loadAvailableModels();
    return service;
  }

  Future<void> _loadAvailableModels() async {
    final startTime = DateTime.now();
    try {
      final connected = await testConnection();
      if (!connected) {
        // 如果连接测试失败，设置默认模型列表
        _availableModels = ['gpt-4o-mini', 'gpt-4o'];
        _model = 'gpt-4o-mini';
      }
    } catch (e) {
      // 加载失败时设置默认模型列表
      _availableModels = ['gpt-4o-mini', 'gpt-4o'];
      _model = 'gpt-4o-mini';
      print('加载模型列表失败: $e');
    } finally {
      print('模型加载耗时: ${DateTime.now().difference(startTime).inMilliseconds}ms');
    }
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
    _loadAvailableModels();
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
      print('API密钥未设置');
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

      print('正在请求模型列表: $modelsUrl');
      final response = await _apiClient.get(modelsUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null || !data.containsKey('data')) {
          print('API响应格式错误');
          return false;
        }

        final modelList =
            (data['data'] as List)
                .map(
                  (model) => {
                    'id': model['id'] as String,
                    'owned_by': model['owned_by'] as String,
                  },
                )
                .toList();

        // 根据owned_by属性过滤和分类模型
        _availableModels =
            modelList
                .where(
                  (model) =>
                      model['owned_by'] == 'openai' || // OpenAI官方模型
                      model['owned_by'] == 'custom' || // 自定义模型
                      model['id'].toString().startsWith('gpt-'),
                ) // 兼容旧版本
                .map((model) => model['id'] as String)
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
