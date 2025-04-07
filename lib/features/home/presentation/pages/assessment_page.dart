import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/llm/llm_provider.dart';
import '../../../../core/llm/llm_service.dart';
import '../../../../core/agent/agent_provider.dart';
import '../widgets/custom_task_view.dart';

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LLMProvider()),
        ChangeNotifierProvider(create: (_) => AgentProvider()),
      ],
      child: const AssessmentView(),
    );
  }
}

class AssessmentView extends StatelessWidget {
  const AssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LLMProvider>();
    final currentService = provider.currentService;

    final agentProvider = context.watch<AgentProvider>();
    final currentAgent = agentProvider.currentRole;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择服务商',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildServiceSelector(context, provider),
            if (currentService != null) ...[
              const SizedBox(height: 24),
              Text(
                '模型描述：${currentService.modelDescription}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                '选择测评任务',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildAgentSelector(context, agentProvider),
              if (currentAgent != null) ...[
                const SizedBox(height: 24),
                Text(
                  '任务描述：${currentAgent.description}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (currentAgent == AgentRole.custom) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => ChangeNotifierProvider.value(
                                value: provider,
                                child: const CustomTaskView(),
                              ),
                        ),
                      );
                    }
                    // TODO: 实现其他角色的测评功能
                  },
                  child: const Text('开始测评'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelector(BuildContext context, LLMProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:
              provider.availableServices.map((service) {
                final isSelected = service == provider.currentService;
                return ListTile(
                  title: Text(service.serviceName),
                  subtitle: Text(service.serviceDescription),
                  leading: Radio<LLMService>(
                    value: service,
                    groupValue: provider.currentService,
                    onChanged: (LLMService? value) {
                      if (value != null) {
                        provider.setCurrentService(value);
                      }
                    },
                  ),
                  selected: isSelected,
                  onTap: () => provider.setCurrentService(service),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildAgentSelector(BuildContext context, AgentProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              provider.availableRoles.map((role) {
                final isSelected = role == provider.currentRole;
                return ListTile(
                  title: Text(role.displayName),
                  subtitle: Text(role.description),
                  leading: Radio<AgentRole>(
                    value: role,
                    groupValue: provider.currentRole,
                    onChanged: (AgentRole? value) {
                      if (value != null) {
                        provider.setCurrentRole(value);
                      }
                    },
                  ),
                  selected: isSelected,
                  onTap: () => provider.setCurrentRole(role),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(LLMService service) {
    final features = {
      LLMFeature.textCompletion: '文本对话',
      LLMFeature.speechToText: '语音转文本',
      LLMFeature.textToSpeech: '文本转语音',
      LLMFeature.imageUnderstanding: '图像理解',
      LLMFeature.imageGeneration: '图像生成',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:
              features.entries.map((entry) {
                final isSupported = service.supportedFeatures.contains(
                  entry.key,
                );
                return ListTile(
                  leading: Icon(
                    isSupported ? Icons.check_circle : Icons.cancel,
                    color: isSupported ? Colors.green : Colors.red,
                  ),
                  title: Text(entry.value),
                  enabled: isSupported,
                  onTap:
                      isSupported
                          ? () {
                            // TODO: 实现具体功能的跳转
                          }
                          : null,
                );
              }).toList(),
        ),
      ),
    );
  }
}
