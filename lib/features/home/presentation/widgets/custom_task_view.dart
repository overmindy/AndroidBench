import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/agent/custom_task_agent.dart';
import '../../../../core/agent/task_type.dart';
import '../../../../core/llm/llm_provider.dart';
import '../../../../core/llm/key_manager.dart';
import '../../../../core/llm/llm_service.dart';

class CustomTaskView extends StatefulWidget {
  const CustomTaskView({super.key});

  @override
  State<CustomTaskView> createState() => _CustomTaskViewState();
}

class _CustomTaskViewState extends State<CustomTaskView> {
  final TextEditingController _textController = TextEditingController();
  String _result = '';
  bool _isProcessing = false;

  late CustomTaskAgent _agent;
  late KeyManager _keyManager;
  String _selectedModel = 'gpt-4o';
  List<String> _availableModels = [];
  String? _apiKey;
  TaskType _selectedTaskType = TaskType.text;

  @override
  void initState() {
    super.initState();
    _agent = CustomTaskAgent(context.read<LLMProvider>());
    _initializeKeyManager();
    _initializeModels();
  }

  void _initializeModels() {
    setState(() {
      _availableModels = _agent.getAvailableModels();
      if (_availableModels.isNotEmpty) {
        _selectedModel = _availableModels[0];
      }
    });
  }

  Future<void> _initializeKeyManager() async {
    _keyManager = await KeyManager.getInstance();
    setState(() {
      _apiKey = _keyManager.getApiKey();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _processText() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _result = '';
    });

    _agent.setModel(_selectedModel);

    try {
      final response = await _agent.processTask(
        _selectedTaskType,
        _textController.text,
      );
      setState(() {
        _result = response;
      });
    } catch (e) {
      setState(() {
        _result = '处理失败: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义任务'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '任务类型',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<TaskType>(
                      value: _selectedTaskType,
                      isExpanded: true,
                      items:
                          TaskType.availableTypes.map((TaskType type) {
                            return DropdownMenuItem<TaskType>(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                      onChanged: (TaskType? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedTaskType = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择模型',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedModel,
                      isExpanded: true,
                      items:
                          _availableModels.map((String model) {
                            return DropdownMenuItem<String>(
                              value: model,
                              child: Text(model),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedModel = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API密钥',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _apiKey != null ? '已配置API密钥' : '未配置API密钥',
                      style: TextStyle(
                        color: _apiKey != null ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 根据任务类型显示不同的界面
            if (_selectedTaskType == TaskType.text) ...[
              // 文本输入区域
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: '输入文本...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // 操作按钮区域
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processText,
                    icon: const Icon(Icons.send),
                    label: Text('处理${_selectedTaskType.displayName}'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 结果展示区域
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      _isProcessing
                          ? const Center(child: CircularProgressIndicator())
                          : SelectableText(
                            _result.isEmpty ? '结果将在这里显示' : _result,
                          ),
                ),
              ),
            ] else ...[
              // 未实现的任务类型显示提示信息
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.construction,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${_selectedTaskType.displayName}功能尚未实现',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
