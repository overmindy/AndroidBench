import 'package:shared_preferences/shared_preferences.dart';
import 'gpt4_service.dart';

class KeyManager {
  static const String _keyStorageKey = 'openai_api_key';
  static const String _baseUrlStorageKey = 'openai_base_url';
  static KeyManager? _instance;
  final SharedPreferences _prefs;

  KeyManager._({required SharedPreferences prefs}) : _prefs = prefs;

  static Future<KeyManager> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = KeyManager._(prefs: prefs);
    }
    return _instance!;
  }

  Future<void> setApiKey(String apiKey) async {
    await _prefs.setString(_keyStorageKey, apiKey);
  }

  String? getApiKey() {
    return _prefs.getString(_keyStorageKey);
  }

  Future<void> removeApiKey() async {
    await _prefs.remove(_keyStorageKey);
  }

  bool hasApiKey() {
    final key = getApiKey();
    return key != null && key.isNotEmpty;
  }

  Future<bool> validateApiKey(String apiKey) async {
    // 验证API密钥格式
    if (!apiKey.startsWith('sk-') || apiKey.length < 32) {
      return false;
    }

    try {
      // 使用GPT4Service进行实际API验证
      final gptService = await GPT4Service.getInstance();
      return await gptService.testConnection();
    } catch (e) {
      return false;
    }
  }

  String getBaseUrl() {
    return _prefs.getString(_baseUrlStorageKey) ?? 'https://api.openai.com/v1';
  }

  Future<void> setBaseUrl(String baseUrl) async {
    await _prefs.setString(_baseUrlStorageKey, baseUrl);
  }
}
