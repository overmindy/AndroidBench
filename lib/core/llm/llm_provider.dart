import 'package:flutter/material.dart';
import 'multi_modal_service.dart';
import 'gpt4_service.dart';

class LLMProvider extends ChangeNotifier {
  static List<MultiModalService> _availableServices = [];

  static Future<void> initializeServices() async {
    final gpt4Service = await GPT4Service.getInstance();
    _availableServices = [gpt4Service];
  }

  MultiModalService? _currentService;

  LLMProvider() {
    initializeServices().then((_) {
      if (_availableServices.isNotEmpty) {
        _currentService = _availableServices.first;
        notifyListeners();
      }
    });
  }

  /// 获取当前选择的多模态服务
  MultiModalService? get currentService => _currentService;

  /// 获取所有可用的多模态服务列表
  List<MultiModalService> get availableServices =>
      List.unmodifiable(_availableServices);

  /// 设置当前使用的多模态服务
  void setCurrentService(MultiModalService service) {
    if (_currentService != service) {
      _currentService = service;
      notifyListeners();
    }
  }

  /// 检查指定功能是否可用
  bool isFeatureSupported(ModalityFeature feature) {
    return _currentService?.supportedFeatures.contains(feature) ?? false;
  }
}
