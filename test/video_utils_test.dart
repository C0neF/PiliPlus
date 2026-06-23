import 'package:PiliPlus/models/common/video/cdn_type.dart';
import 'package:PiliPlus/utils/video_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('removes mcdn port when rewriting upgcxcode urls to default CDN', () {
    final result = VideoUtils.getCdnUrl(
      [
        'https://upos-sz-mirrorali.bilivideo.com:4483/upgcxcode/08/07/video.m4s?platform=android&os=mcdn',
      ],
      defaultCDNService: CDNService.backupUrl,
    );

    expect(
      result,
      startsWith('https://upos-sz-mirrorali.bilivideo.com/upgcxcode/'),
    );
    expect(result, isNot(contains(':4483')));
    expect(Uri.parse(result).port, 443);
  });
}
