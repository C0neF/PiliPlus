import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/pages/webdav/webdav.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebDavConfig', () {
    test('normalizes form input before saving', () {
      final config = WebDavConfig.fromInput(
        uri: ' https://dav.jianguoyun.com/dav/ ',
        username: ' user@example.com ',
        password: ' password with spaces ',
        directory: ' / ',
      );

      expect(config.uri, 'https://dav.jianguoyun.com/dav/');
      expect(config.username, 'user@example.com');
      expect(config.password, ' password with spaces ');
      expect(config.directory, '/');
      expect(config.toStorageMap(), {
        SettingBoxKey.webdavUri: 'https://dav.jianguoyun.com/dav/',
        SettingBoxKey.webdavUsername: 'user@example.com',
        SettingBoxKey.webdavPassword: ' password with spaces ',
        SettingBoxKey.webdavDirectory: '/',
      });
    });

    test('builds the app directory inside the configured root', () {
      expect(
        WebDavConfig.fromInput(
          uri: 'https://dav.example.com/dav/',
          username: '',
          password: '',
          directory: '/',
        ).appDirectory,
        '/${Constants.appName}',
      );

      expect(
        WebDavConfig.fromInput(
          uri: 'https://dav.example.com/dav/',
          username: '',
          password: '',
          directory: '/backups/',
        ).appFilePath('settings.json'),
        '/backups/${Constants.appName}/settings.json',
      );
    });

    test('rejects empty or hostless WebDAV uri before creating the client', () {
      expect(
        WebDavConfig.fromInput(
          uri: '',
          username: '',
          password: '',
          directory: '/',
        ).validate(),
        'WebDAV 地址不能为空',
      );

      expect(
        WebDavConfig.fromInput(
          uri: '/PiliPlus/',
          username: '',
          password: '',
          directory: '/',
        ).validate(),
        'WebDAV 地址格式无效',
      );
    });
  });
}
