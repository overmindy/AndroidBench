import 'package:flutter/material.dart';
import 'llm_service.dart';
import 'gpt4_service.dart';
import 'deepseek_service.dart';

class LLMProvider extends ChangeNotifier {
  static List<LLMService> _availableServices = [];

  static Future<void> initializeServices() async {
    final gpt4Service = await GPT4Service.getInstance();
    _availableServices = [gpt4Service];
  }

  LLMService? _currentService;

  LLMProvider() {
    initializeServices().then((_) {
      if (_availableServices.isNotEmpty) {
        _currentService = _availableServices.first;
        notifyListeners();
      }
    });
  }

  /// 获取当前选择的LLM服务
  LLMService? get currentService => _currentService;

  /// 获取所有可用的LLM服务列表
  List<LLMService> get availableServices =>
      List.unmodifiable(_availableServices);

  /// 设置当前使用的LLM服务
  void setCurrentService(LLMService service) {
    if (_currentService != service) {
      _currentService = service;
      notifyListeners();
    }
  }

  /// 检查指定功能是否可用
  bool isFeatureSupported(LLMFeature feature) {
    return _currentService?.supportedFeatures.contains(feature) ?? false;
  }
}
