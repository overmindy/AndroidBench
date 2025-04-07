import 'package:flutter/material.dart';

enum AgentRole {
  assistant('智能助手', '通用对话和任务处理能力测试'),
  coder('代码专家', '编程和代码理解能力测试'),
  teacher('教育导师', '知识传授和解释能力测试'),
  writer('文案创作', '文字创作和内容生成能力测试'),
  custom('自定义任务', '自定义特定场景的任务测试');

  final String displayName;
  final String description;

  const AgentRole(this.displayName, this.description);
}

class AgentProvider extends ChangeNotifier {
  AgentRole? _currentRole;

  AgentRole? get currentRole => _currentRole;

  List<AgentRole> get availableRoles => AgentRole.values;

  void setCurrentRole(AgentRole? role) {
    if (_currentRole != role) {
      _currentRole = role;
      notifyListeners();
    }
  }
}
