import 'key_manager.dart';
import 'multi_modal_service.dart';

/// 基于API的多模态服务基类
abstract class ApiService implements MultiModalService {
  final KeyManager keyManager;
  ApiService({required this.keyManager});

  /// 获取API密钥
  String? get apiKey => keyManager.getApiKey();

  /// 获取API请求头
  Map<String, String> get headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  /// 检查API密钥是否有效
  bool get isKeyValid => apiKey?.isNotEmpty ?? false;

  /// 检查服务是否可用
  bool get isServiceAvailable => isKeyValid;

  /// 获取API版本
  String get apiVersion;

  /// 获取API端点URL
  String getEndpoint(String path) => '${keyManager.getBaseUrl()}$path';
}
