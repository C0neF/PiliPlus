import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/playurl_merge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('merges a trial video stream into the current playurl data', () {
    final current = PlayUrlModel(
      acceptQuality: [VideoQuality.high1080.code],
      supportFormats: [
        FormatItem(
          quality: VideoQuality.high1080.code,
          newDesc: VideoQuality.high1080.desc,
          codecs: ['avc1'],
        ),
      ],
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.high1080.code,
            baseUrl: 'https://example.com/1080.m4s',
            codecs: 'avc1',
            quality: VideoQuality.high1080,
          ),
        ],
        audio: [
          AudioItem()
            ..id = 30280
            ..baseUrl = 'https://example.com/audio.m4s'
            ..quality = '192K',
        ],
      ),
    );
    final trial = PlayUrlModel(
      acceptQuality: [VideoQuality.super4K.code],
      supportFormats: [
        FormatItem(
          quality: VideoQuality.super4K.code,
          newDesc: VideoQuality.super4K.desc,
          codecs: ['hev1'],
        ),
      ],
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.super4K.code,
            baseUrl: 'https://example.com/4k.m4s',
            codecs: 'hev1',
            quality: VideoQuality.super4K,
          ),
        ],
        audio: [
          AudioItem()
            ..id = 30232
            ..baseUrl = 'https://example.com/audio-132.m4s'
            ..quality = '132K',
        ],
      ),
    );

    final merged = mergePlayUrlDashStreams(
      current: current,
      incoming: trial,
      quality: VideoQuality.super4K.code,
    );

    expect(merged, isTrue);
    expect(current.dash?.video?.map((item) => item.quality).toList(), [
      VideoQuality.super4K,
      VideoQuality.high1080,
    ]);
    expect(current.dash?.audio?.map((item) => item.id).toList(), [
      30280,
      30232,
    ]);
    expect(current.acceptQuality, [
      VideoQuality.high1080.code,
      VideoQuality.super4K.code,
    ]);
    expect(
      current.supportFormats?.map((item) => item.quality).toList(),
      [VideoQuality.high1080.code, VideoQuality.super4K.code],
    );
  });

  test('replaces matching audio streams with trial playurl audio', () {
    final current = PlayUrlModel(
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.high1080.code,
            baseUrl: 'https://example.com/1080.m4s',
            codecs: 'avc1',
            quality: VideoQuality.high1080,
          ),
        ],
        audio: [
          AudioItem()
            ..id = 30280
            ..baseUrl = 'https://web.example.com/audio.m4s'
            ..quality = '192K',
        ],
      ),
    );
    final trial = PlayUrlModel(
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.super4K.code,
            baseUrl: 'https://app.example.com/4k.m4s',
            codecs: 'hev1',
            quality: VideoQuality.super4K,
          ),
        ],
        audio: [
          AudioItem()
            ..id = 30280
            ..baseUrl = 'https://app.example.com/audio.m4s'
            ..quality = '192K',
        ],
      ),
    );

    final merged = mergePlayUrlDashStreams(
      current: current,
      incoming: trial,
      quality: VideoQuality.super4K.code,
    );

    expect(merged, isTrue);
    expect(current.dash?.audio?.single.id, 30280);
    expect(
      current.dash?.audio?.single.baseUrl,
      'https://app.example.com/audio.m4s',
    );
  });

  test(
    'continues to the next trial source when the first source lacks quality',
    () async {
      final current = PlayUrlModel(
        dash: Dash(
          video: [
            VideoItem(
              id: VideoQuality.high1080.code,
              baseUrl: 'https://example.com/1080.m4s',
              codecs: 'avc1',
              quality: VideoQuality.high1080,
            ),
          ],
        ),
      );
      final missing4K = PlayUrlModel(
        dash: Dash(
          video: [
            VideoItem(
              id: VideoQuality.high1080.code,
              baseUrl: 'https://grpc.example.com/1080.m4s',
              codecs: 'avc1',
              quality: VideoQuality.high1080,
            ),
          ],
        ),
      );
      final webTrial4K = PlayUrlModel(
        acceptQuality: [VideoQuality.super4K.code],
        supportFormats: [
          FormatItem(
            quality: VideoQuality.super4K.code,
            newDesc: VideoQuality.super4K.desc,
            codecs: ['hev1'],
          ),
        ],
        dash: Dash(
          video: [
            VideoItem(
              id: VideoQuality.super4K.code,
              baseUrl: 'https://web.example.com/4k.m4s',
              codecs: 'hev1',
              quality: VideoQuality.super4K,
            ),
          ],
        ),
      );

      var sourceCalls = 0;
      final merged = await mergePlayUrlDashStreamsFromSources(
        current: current,
        quality: VideoQuality.super4K.code,
        sources: [
          PlayUrlMergeSource(
            load: () async {
              sourceCalls++;
              return Success(missing4K);
            },
            requiresAppMediaHeaders: true,
          ),
          PlayUrlMergeSource(
            load: () async {
              sourceCalls++;
              return Success(webTrial4K);
            },
          ),
        ],
      );

      expect(merged.success, isTrue);
      expect(merged.requiresAppMediaHeaders, isFalse);
      expect(sourceCalls, 2);
      expect(current.dash?.video?.first.quality, VideoQuality.super4K);
      expect(
        current.dash?.video?.first.baseUrl,
        'https://web.example.com/4k.m4s',
      );
    },
  );
}
