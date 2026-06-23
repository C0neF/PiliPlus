import 'dart:convert';

import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/pair.dart';
import 'package:PiliPlus/utils/device_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

class WebDavConfig {
  const WebDavConfig({
    required this.uri,
    required this.username,
    required this.password,
    required this.directory,
  });

  factory WebDavConfig.fromInput({
    required String uri,
    required String username,
    required String password,
    required String directory,
  }) {
    return WebDavConfig(
      uri: uri.trim(),
      username: username.trim(),
      password: password,
      directory: _normalizeDirectory(directory),
    );
  }

  factory WebDavConfig.fromPreferences() {
    return WebDavConfig.fromInput(
      uri: Pref.webdavUri,
      username: Pref.webdavUsername,
      password: Pref.webdavPassword,
      directory: Pref.webdavDirectory,
    );
  }

  final String uri;
  final String username;
  final String password;
  final String directory;

  Map<String, String> toStorageMap() => {
    SettingBoxKey.webdavUri: uri,
    SettingBoxKey.webdavUsername: username,
    SettingBoxKey.webdavPassword: password,
    SettingBoxKey.webdavDirectory: directory,
  };

  String? validate() {
    if (uri.isEmpty) {
      return 'WebDAV 地址不能为空';
    }
    final parsed = Uri.tryParse(uri);
    if (parsed == null ||
        !parsed.hasScheme ||
        parsed.host.isEmpty ||
        (parsed.scheme != 'http' && parsed.scheme != 'https')) {
      return 'WebDAV 地址格式无效';
    }
    return null;
  }

  String get appDirectory {
    if (directory == '/') {
      return '/${Constants.appName}';
    }
    return '${_trimRightSlash(directory)}/${Constants.appName}';
  }

  String appFilePath(String fileName) => '$appDirectory/$fileName';

  static String _normalizeDirectory(String value) {
    var directory = value.trim().replaceAll('\\', '/');
    if (directory.isEmpty) {
      return '/';
    }
    directory = directory.replaceAll(RegExp(r'/+'), '/');
    if (!directory.startsWith('/')) {
      directory = '/$directory';
    }
    if (directory.length > 1) {
      directory = _trimRightSlash(directory);
    }
    return directory;
  }

  static String _trimRightSlash(String value) {
    var result = value;
    while (result.length > 1 && result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
}

class WebDav {
  late String _webdavDirectory;
  String? _fileName;

  webdav.Client? _client;

  WebDav._internal();
  static final WebDav _instance = WebDav._internal();
  factory WebDav() => _instance;

  Future<Pair<bool, String?>> init() async {
    final config = WebDavConfig.fromPreferences();
    final error = config.validate();
    if (error != null) {
      _client = null;
      return Pair(first: false, second: error);
    }
    _webdavDirectory = config.appDirectory;

    try {
      _client = null;
      final client =
          webdav.newClient(
              config.uri,
              user: config.username,
              password: config.password,
            )
            ..setHeaders({'accept-charset': 'utf-8'})
            ..setConnectTimeout(12000)
            ..setReceiveTimeout(12000)
            ..setSendTimeout(12000);

      await client.mkdirAll(_webdavDirectory);

      _client = client;
      return Pair(first: true, second: null);
    } catch (e) {
      return Pair(first: false, second: e.toString());
    }
  }

  String _getFileName() {
    return 'piliplus_settings_${DeviceUtils.platformName}.json';
  }

  Future<void> backup() async {
    final res = await init();
    if (!res.first) {
      SmartDialog.showToast('备份失败，请检查配置: ${res.second}');
      return;
    }
    try {
      String data = GStorage.exportAllSettings();
      _fileName ??= _getFileName();
      final path = '$_webdavDirectory/$_fileName';
      try {
        await _client!.remove(path);
      } catch (_) {}
      await _client!.write(path, utf8.encode(data));
      SmartDialog.showToast('备份成功');
    } catch (e) {
      SmartDialog.showToast('备份失败: $e');
    }
  }

  Future<void> restore() async {
    final res = await init();
    if (!res.first) {
      SmartDialog.showToast('恢复失败，请检查配置: ${res.second}');
      return;
    }
    try {
      _fileName ??= _getFileName();
      final path = '$_webdavDirectory/$_fileName';
      final data = await _client!.read(path);
      await GStorage.importAllSettings(utf8.decode(data));
      SmartDialog.showToast('恢复成功');
    } catch (e) {
      SmartDialog.showToast('恢复失败: $e');
    }
  }
}
