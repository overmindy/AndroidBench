import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/llm/key_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '';
  bool _cameraPermission = false;
  bool _microphonePermission = false;
  bool _storagePermission = false;
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late KeyManager _keyManager;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _checkPermissions();
    _initKeyManager();
  }

  Future<void> _initKeyManager() async {
    _keyManager = await KeyManager.getInstance();
    final currentKey = _keyManager.getApiKey();
    if (currentKey != null) {
      _apiKeyController.text = currentKey;
    }
    _baseUrlController.text = _keyManager.getBaseUrl();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  Future<void> _checkPermissions() async {
    if (kIsWeb) {
      setState(() {
        _cameraPermission = false;
        _microphonePermission = false;
        _storagePermission = false;
      });
      return;
    }

    final camera = await Permission.camera.status;
    final microphone = await Permission.microphone.status;
    final storage = await Permission.storage.status;

    setState(() {
      _cameraPermission = camera.isGranted;
      _microphonePermission = microphone.isGranted;
      _storagePermission = storage.isGranted;
    });
  }

  Future<void> _requestPermission(Permission permission) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Web平台不支持权限管理')));
      return;
    }

    final status = await permission.request();
    setState(() {
      switch (permission) {
        case Permission.camera:
          _cameraPermission = status.isGranted;
          break;
        case Permission.microphone:
          _microphonePermission = status.isGranted;
          break;
        case Permission.storage:
          _storagePermission = status.isGranted;
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('版本信息'),
            subtitle: Text('当前版本：$_version'),
          ),
          const Divider(),
          const ListTile(leading: Icon(Icons.security), title: Text('权限管理')),
          SwitchListTile(
            secondary: const Icon(Icons.camera_alt),
            title: const Text('相机权限'),
            value: _cameraPermission,
            onChanged: (value) => _requestPermission(Permission.camera),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.mic),
            title: const Text('麦克风权限'),
            value: _microphonePermission,
            onChanged: (value) => _requestPermission(Permission.microphone),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.storage),
            title: const Text('存储权限'),
            value: _storagePermission,
            onChanged: (value) => _requestPermission(Permission.storage),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('API配置'),
            subtitle: const Text('配置GPT-4和Deepseek API密钥'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/api-config'),
          ),
          const Divider(),
          Consumer<ThemeManager>(
            builder:
                (context, themeManager, child) => SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('深色模式'),
                  value: themeManager.isDarkMode,
                  onChanged: (value) => themeManager.toggleTheme(),
                ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('清除缓存'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 实现清除缓存功能
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于我们'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 实现关于我们页面
            },
          ),
        ],
      ),
    );
  }
}
