import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import '../../../../core/agent/custom_task_agent.dart';
import '../../../../core/agent/task_type.dart';
import '../../../../core/llm/llm_provider.dart';
import '../../../../core/llm/key_manager.dart';

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

  // 多媒体文件相关变量
  Uint8List? _selectedFileData;
  String? _selectedFileName;
  bool _isRecording = false;

  // 多模态任务的文本输入控制器
  final TextEditingController _imageTextController = TextEditingController();
  final TextEditingController _videoTextController = TextEditingController();
  final TextEditingController _audioTextController = TextEditingController();

  // 文件选择方法
  Future<void> _pickFile(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type:
            type == 'image'
                ? FileType.image
                : type == 'video'
                ? FileType.video
                : FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedFileData = result.files.first.bytes!;
          _selectedFileName = result.files.first.name;
        });
      }
    } catch (e) {
      setState(() {
        _result = '文件选择失败: $e';
      });
    }
  }

  // 录音相关方法
  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      try {
        final hasPermission = await Permission.microphone.request().isGranted;
        if (!hasPermission) {
          setState(() {
            _result = '需要麦克风权限才能录音';
          });
          return;
        }

        // TODO: 实现录音功能
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        setState(() {
          _result = '录音失败: $e';
        });
      }
    } else {
      try {
        // TODO: 停止录音并获取录音文件
        setState(() {
          _isRecording = false;
        });
      } catch (e) {
        setState(() {
          _result = '停止录音失败: $e';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeKeyManager();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // if (_agent == null) {
    _agent = CustomTaskAgent(context.read<LLMProvider>());
    _initializeModels();
    // }
  }

  Future<void> _initializeModels() async {
    setState(() {
      _availableModels = [];
    });
    final models = await _agent.getAvailableModels();
    setState(() {
      _availableModels = models;
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

  Future<void> _processTask() async {
    String input = '';
    if (_selectedTaskType == TaskType.text) {
      if (_textController.text.isEmpty) return;
      input = _textController.text;
    } else {
      if (_selectedFileData == null) {
        setState(() {
          _result = '请先选择媒体文件';
        });
        return;
      }

      // 获取对应任务类型的文本输入
      String? textInput;
      switch (_selectedTaskType) {
        case TaskType.image:
          textInput = _imageTextController.text;
          break;
        case TaskType.video:
          textInput = _videoTextController.text;
          break;
        case TaskType.audio:
          textInput = _audioTextController.text;
          break;
        default:
          break;
      }

      // 如果有文本输入，将其与文件数据一起处理
      if (textInput != null && textInput.isNotEmpty) {
        input = textInput;
      }
    }

    setState(() {
      _isProcessing = true;
      _result = '';
    });

    _agent.setModel(_selectedModel);

    try {
      final response = await _agent.processTask(
        _selectedTaskType,
        _selectedTaskType == TaskType.text ? input : _selectedFileData!,
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
      extendBody: true,
      appBar: AppBar(
        title: const Text('自定义任务'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '选择模型',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            setState(() {
                              _availableModels = [];
                              _initializeModels();
                            });
                          },
                          tooltip: '刷新模型列表',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedModel,
                      isExpanded: true,
                      items:
                          _availableModels.isEmpty
                              ? []
                              : _availableModels.map((String model) {
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
                      hint: const Text('加载中...'),
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
                    onPressed: _isProcessing ? null : _processTask,
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
            ] else if (_selectedTaskType == TaskType.image) ...[
              // 图片选择和预览区域
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickFile('image'),
                    icon: const Icon(Icons.image),
                    label: const Text('选择图片'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processTask,
                    icon: const Icon(Icons.send),
                    label: const Text('处理图片'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 图片任务的文本输入
              TextField(
                controller: _imageTextController,
                decoration: const InputDecoration(
                  hintText: '输入图片相关的文本描述或提示...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // 图片预览和结果显示区域
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
                          : _selectedFileData != null
                          ? Column(
                            children: [
                              Expanded(child: Image.memory(_selectedFileData!)),
                              if (_result.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                SelectableText(_result),
                              ],
                            ],
                          )
                          : const Center(child: Text('选择图片以开始处理')),
                ),
              ),
            ] else if (_selectedTaskType == TaskType.video) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickFile('video'),
                    icon: const Icon(Icons.video_library),
                    label: const Text('选择视频'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processTask,
                    icon: const Icon(Icons.send),
                    label: const Text('处理视频'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 视频任务的文本输入
              TextField(
                controller: _videoTextController,
                decoration: const InputDecoration(
                  hintText: '输入视频相关的文本描述或提示...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // 视频预览和结果显示区域
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
                          : Column(
                            children: [
                              if (_selectedFileName != null)
                                Text('已选择视频: $_selectedFileName'),
                              if (_result.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: SelectableText(_result),
                                  ),
                                ),
                              ],
                            ],
                          ),
                ),
              ),
            ] else if (_selectedTaskType == TaskType.audio) ...[
              // 语音录制和播放区域
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _toggleRecording,
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                    label: Text(_isRecording ? '停止录音' : '开始录音'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickFile('audio'),
                    icon: const Icon(Icons.audio_file),
                    label: const Text('选择音频'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processTask,
                    icon: const Icon(Icons.send),
                    label: const Text('处理音频'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 音频任务的文本输入
              TextField(
                controller: _audioTextController,
                decoration: const InputDecoration(
                  hintText: '输入音频相关的文本描述或提示...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // 音频播放和结果显示区域
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
                          : Column(
                            children: [
                              if (_selectedFileName != null)
                                Text('已选择音频: $_selectedFileName'),
                              if (_result.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: SelectableText(_result),
                                  ),
                                ),
                              ],
                            ],
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
