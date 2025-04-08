import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'key_manager.dart';
import 'multi_modal_service.dart';
import 'api_service.dart';

class GPT4Service extends ApiService implements MultiModalService {
  String _model = 'gpt-4o';
  List<String> _availableModels = [];

  GPT4Service._({required KeyManager keyManager})
    : super(keyManager: keyManager);

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
        _availableModels = ['gpt-4o-mini', 'gpt-4o'];
        _model = 'gpt-4o-mini';
      }
    } catch (e) {
      _availableModels = ['gpt-4o-mini', 'gpt-4o'];
      _model = 'gpt-4o-mini';
      print('加载模型列表失败: $e');
    } finally {
      print('模型加载耗时: ${DateTime.now().difference(startTime).inMilliseconds}ms');
    }
  }

  @override
  Future<String> textToText(String text) async {
    final response = await post(
      '/chat/completions',
      data: {
        'model': _model,
        'messages': [
          {'role': 'user', 'content': text},
        ],
        'temperature': 0.7,
        'max_tokens': 1000,
      },
    );
    return response['choices'][0]['message']['content'];
  }

  @override
  Future<String> speechToText(Uint8List audioData) async {
    final response = await post(
      '/audio/transcriptions',
      data: {'file': audioData, 'model': _model, 'response_format': 'text'},
    );
    return response.toString();
  }

  @override
  Future<Uint8List> textToSpeech(String text) async {
    final response = await post(
      '/audio/speech',
      data: {'model': _model, 'input': text, 'voice': 'alloy'},
    );
    return handleBinaryResponse(response);
  }

  @override
  Future<String> imageToText(Uint8List imageData) async {
    final response = await post(
      '/chat/completions',
      data: {
        'model': _model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,${base64Encode(imageData)}',
                },
              },
              {'type': 'text', 'text': '请描述这张图片'},
            ],
          },
        ],
        'max_tokens': 300,
      },
    );
    return response['choices'][0]['message']['content'];
  }

  @override
  Future<Uint8List> textToImage(String text) async {
    final response = await post(
      '/images/generations',
      data: {'model': 'dall-e-3', 'prompt': text, 'n': 1, 'size': '1024x1024'},
    );
    return handleBinaryResponse(response);
  }

  @override
  Future<String> textImageToText(String text, Uint8List imageData) {
    throw UnimplementedError();
  }

  @override
  Future<String> textSpeechToText(String text, Uint8List audioData) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> textImageToSpeech(String text, Uint8List imageData) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> textSpeechToSpeech(String text, Uint8List audioData) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> speechToSpeech(Uint8List audioData) {
    throw UnimplementedError();
  }

  @override
  String get serviceName => 'GPT-4';

  @override
  String get serviceDescription => 'OpenAI GPT-4 多模态服务';

  @override
  List<ModalityFeature> get supportedFeatures => [
    ModalityFeature.textToText,
    ModalityFeature.speechToText,
    ModalityFeature.textToSpeech,
    ModalityFeature.imageToText,
    ModalityFeature.textToImage,
  ];

  @override
  List<String> get availableModels => _availableModels;

  @override
  String? get currentModel => _model;

  @override
  void setCurrentModel(String model) {
    if (_availableModels.contains(model)) {
      _model = model;
    }
  }

  @override
  String get modelDescription => '当前使用的模型: $_model';

  @override
  String get apiVersion => 'v1';

  Future<bool> testConnection() async {
    try {
      final response = await get('/models');
      final data = response;
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
    } catch (e) {
      print('测试连接失败: $e');
      return false;
    }
  }

  Future<Uint8List> handleBinaryResponse(dynamic response) async {
    if (response is List<int>) {
      return Uint8List.fromList(response);
    }
    throw Exception('Invalid binary response');
  }

  Future<dynamic> get(String path) async {
    if (!isServiceAvailable) {
      throw Exception('API服务不可用');
    }
    final dio = Dio();
    try {
      final response = await dio.get(
        getEndpoint(path),
        options: Options(headers: headers),
      );

      if (response.statusCode != 200) {
        throw Exception('请求失败: ${response.statusCode} - ${response.data}');
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception('请求失败: ${e.message}');
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    if (!isServiceAvailable) {
      throw Exception('API服务不可用');
    }
    final dio = Dio();
    try {
      final response = await dio.post(
        getEndpoint(path),
        data: data,
        options: Options(headers: headers, responseType: ResponseType.json),
      );

      if (response.statusCode != 200) {
        throw Exception('请求失败: ${response.statusCode} - ${response.data}');
      }

      // 处理二进制响应
      if (response.headers.map['content-type']?.first.contains(
            'application/octet-stream',
          ) ??
          false) {
        if (response.data is List<int>) {
          return response.data;
        }
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception('请求失败: ${e.message}');
    }
  }
}
