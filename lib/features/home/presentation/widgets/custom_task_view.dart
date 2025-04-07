import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/agent/custom_task_agent.dart';
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
  String _baseUrl = '';
  String _selectedModel = 'gpt-4o';
  List<String> _availableModels = [];

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
      _baseUrl = _keyManager.getBaseUrl();
    });
  }

  Future<void> _updateBaseUrl(String newBaseUrl) async {
    await _keyManager.setBaseUrl(newBaseUrl);
    setState(() {
      _baseUrl = newBaseUrl;
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
      final response = await _agent.processText(_textController.text);
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
            // BaseURL输入区域
            TextField(
              decoration: InputDecoration(
                labelText: 'Base URL',
                hintText: '输入API基础地址',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _baseUrl),
              onChanged: _updateBaseUrl,
            ),
            const SizedBox(height: 16),

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
                  label: const Text('发送文本'),
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
          ],
        ),
      ),
    );
  }
}
