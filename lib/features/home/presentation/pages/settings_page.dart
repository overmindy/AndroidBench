import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
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
  bool _allPermissions = false;
  bool _accessibilityPermission = false;
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
        _allPermissions = false;
        _accessibilityPermission = false;
      });
      return;
    }

    final allPermissions = await Permission.requestInstallPackages.status;
    final accessibility =
        await FlutterAccessibilityService.isAccessibilityPermissionEnabled();

    setState(() {
      _allPermissions = allPermissions.isGranted;
      _accessibilityPermission = accessibility;
    });
  }

  Future<void> _requestPermission(Permission permission) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Web平台不支持权限管理')));
      return;
    }

    // 根据权限类型选择不同的跳转方式
    if (permission == Permission.systemAlertWindow) {
      await FlutterAccessibilityService.requestAccessibilityPermission();
    } else {
      await openAppSettings();
    }

    // 检查权限状态
    final status = await permission.status;
    setState(() {
      switch (permission) {
        case Permission.requestInstallPackages:
          _allPermissions = status.isGranted;
          break;
        case Permission.systemAlertWindow:
          _accessibilityPermission = status.isGranted;
          break;
        default:
          break;
      }
    });

    // 显示提示信息
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请在系统设置中手动开启所需权限')));
      }
    }
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
            secondary: const Icon(Icons.admin_panel_settings),
            title: const Text('所有权限'),
            value: _allPermissions,
            onChanged:
                (value) =>
                    _requestPermission(Permission.requestInstallPackages),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.accessibility_new),
            title: const Text('无障碍权限'),
            value: _accessibilityPermission,
            onChanged:
                (value) => _requestPermission(Permission.systemAlertWindow),
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
