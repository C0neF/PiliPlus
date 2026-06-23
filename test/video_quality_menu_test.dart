import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:PiliPlus/utils/video_quality_menu.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds a playable 4K trial option when 4K exists in support formats', () {
    final playUrl = PlayUrlModel(
      supportFormats: [
        FormatItem(
          quality: VideoQuality.super4K.code,
          newDesc: '4K 超高清',
          format: 'flv',
        ),
        FormatItem(
          quality: VideoQuality.high1080.code,
          newDesc: '1080P 高清',
          format: 'flv',
        ),
      ],
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.super4K.code,
            quality: VideoQuality.super4K,
          ),
          VideoItem(
            id: VideoQuality.high1080.code,
            quality: VideoQuality.high1080,
          ),
        ],
      ),
    );

    final entries = buildVideoQualityMenuEntries(playUrl);

    expect(entries.map((e) => e.label), ['4K 超高清', '4K试看', '1080P 高清']);
    final trial = entries.singleWhere((e) => e.isTrial);
    expect(trial.quality, VideoQuality.super4K.code);
    expect(trial.enabled, isTrue);
  });

  test('enables 4K trial when 4K is advertised without a 4K stream', () {
    final playUrl = PlayUrlModel(
      supportFormats: [
        FormatItem(
          quality: VideoQuality.super4K.code,
          newDesc: '4K 超高清',
          format: 'flv',
        ),
        FormatItem(
          quality: VideoQuality.high1080.code,
          newDesc: '1080P 高清',
          format: 'flv',
        ),
      ],
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.high1080.code,
            quality: VideoQuality.high1080,
          ),
        ],
      ),
    );

    final entries = buildVideoQualityMenuEntries(playUrl);

    final normal4K = entries.singleWhere(
      (e) => e.quality == VideoQuality.super4K.code && !e.isTrial,
    );
    expect(normal4K.enabled, isFalse);

    final trial = entries.singleWhere((e) => e.isTrial);
    expect(trial.label, '4K试看');
    expect(trial.enabled, isTrue);
    expect(
      entries
          .singleWhere((e) => e.quality == VideoQuality.high1080.code)
          .enabled,
      isTrue,
    );
  });

  test('adds a playable 1080P high frame rate trial option', () {
    final playUrl = PlayUrlModel(
      supportFormats: [
        FormatItem(
          quality: VideoQuality.high108060.code,
          newDesc: VideoQuality.high108060.desc,
          format: 'flv',
        ),
        FormatItem(
          quality: VideoQuality.high1080.code,
          newDesc: '1080P 高清',
          format: 'flv',
        ),
      ],
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.high1080.code,
            quality: VideoQuality.high1080,
          ),
        ],
      ),
    );

    final entries = buildVideoQualityMenuEntries(playUrl);

    final normalHighFrame = entries.singleWhere(
      (e) => e.quality == VideoQuality.high108060.code && !e.isTrial,
    );
    expect(normalHighFrame.enabled, isFalse);

    final trial = entries.singleWhere(
      (e) => e.quality == VideoQuality.high108060.code && e.isTrial,
    );
    expect(trial.label, '1080P60试看');
    expect(trial.enabled, isTrue);
    expect(trial.popupValue, -VideoQuality.high108060.code);
  });

  test('adds a playable 1080P high bitrate trial option', () {
    final playUrl = PlayUrlModel(
      supportFormats: [
        FormatItem(
          quality: VideoQuality.high1080plus.code,
          newDesc: VideoQuality.high1080plus.desc,
          format: 'hdflv2',
        ),
        FormatItem(
          quality: VideoQuality.high1080.code,
          newDesc: '1080P 高清',
          format: 'flv',
        ),
      ],
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.high1080.code,
            quality: VideoQuality.high1080,
          ),
        ],
      ),
    );

    final entries = buildVideoQualityMenuEntries(playUrl);

    final normalHighBitrate = entries.singleWhere(
      (e) => e.quality == VideoQuality.high1080plus.code && !e.isTrial,
    );
    expect(normalHighBitrate.enabled, isFalse);

    final trial = entries.singleWhere(
      (e) => e.quality == VideoQuality.high1080plus.code && e.isTrial,
    );
    expect(trial.label, '1080P+试看');
    expect(trial.enabled, isTrue);
    expect(trial.popupValue, -VideoQuality.high1080plus.code);
  });

  test('adds a playable Dolby Vision trial option', () {
    final playUrl = PlayUrlModel(
      supportFormats: [
        FormatItem(
          quality: VideoQuality.dolbyVision.code,
          newDesc: VideoQuality.dolbyVision.desc,
          format: 'flv',
        ),
        FormatItem(
          quality: VideoQuality.high1080.code,
          newDesc: '1080P 高清',
          format: 'flv',
        ),
      ],
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.high1080.code,
            quality: VideoQuality.high1080,
          ),
        ],
      ),
    );

    final entries = buildVideoQualityMenuEntries(playUrl);

    final normalDolbyVision = entries.singleWhere(
      (e) => e.quality == VideoQuality.dolbyVision.code && !e.isTrial,
    );
    expect(normalDolbyVision.enabled, isFalse);

    final trial = entries.singleWhere(
      (e) => e.quality == VideoQuality.dolbyVision.code && e.isTrial,
    );
    expect(trial.label, '杜比视界试看');
    expect(trial.enabled, isTrue);
    expect(trial.popupValue, -VideoQuality.dolbyVision.code);
  });

  test('adds additional premium trial options', () {
    final playUrl = PlayUrlModel(
      supportFormats: [
        FormatItem(
          quality: VideoQuality.hdrVivid.code,
          newDesc: VideoQuality.hdrVivid.desc,
          format: 'flv',
        ),
        FormatItem(
          quality: VideoQuality.super8k.code,
          newDesc: VideoQuality.super8k.desc,
          format: 'flv',
        ),
        FormatItem(
          quality: VideoQuality.hdr.code,
          newDesc: VideoQuality.hdr.desc,
          format: 'flv',
        ),
        FormatItem(
          quality: VideoQuality.high72060.code,
          newDesc: VideoQuality.high72060.desc,
          format: 'flv',
        ),
        FormatItem(
          quality: VideoQuality.high1080.code,
          newDesc: '1080P 高清',
          format: 'flv',
        ),
      ],
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.high1080.code,
            quality: VideoQuality.high1080,
          ),
        ],
      ),
    );

    final entries = buildVideoQualityMenuEntries(playUrl);
    final trialLabels = Map<int, String>.fromEntries(
      entries
          .where((entry) => entry.isTrial)
          .map((entry) => MapEntry(entry.quality, entry.label)),
    );

    expect(trialLabels[VideoQuality.hdrVivid.code], 'HDR Vivid试看');
    expect(trialLabels[VideoQuality.super8k.code], '8K试看');
    expect(trialLabels[VideoQuality.hdr.code], 'HDR试看');
    expect(trialLabels[VideoQuality.high72060.code], '720P60试看');
    expect(
      entries
          .singleWhere(
            (entry) =>
                entry.quality == VideoQuality.hdrVivid.code && !entry.isTrial,
          )
          .enabled,
      isFalse,
    );
  });

  test('does not add 4K trial when the video has no 4K quality', () {
    final playUrl = PlayUrlModel(
      supportFormats: [
        FormatItem(
          quality: VideoQuality.high1080.code,
          newDesc: '1080P 高清',
          format: 'flv',
        ),
      ],
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.high1080.code,
            quality: VideoQuality.high1080,
          ),
        ],
      ),
    );

    final entries = buildVideoQualityMenuEntries(playUrl);

    expect(entries.any((e) => e.isTrial), isFalse);
    expect(entries.map((e) => e.label), ['1080P 高清']);
  });

  test('builds default video quality setting options with trial labels', () {
    final options = buildVideoQualitySettingOptions();
    final labels = Map<int, String>.fromEntries(
      options.map((item) => MapEntry(item.$1, item.$2)),
    );

    expect(options.map((item) => item.$1).toSet().length, options.length);
    expect(labels[VideoQuality.super4K.code], '4K试看');
    expect(labels[VideoQuality.hdrVivid.code], 'HDR Vivid试看');
    expect(labels[VideoQuality.super8k.code], '8K试看');
    expect(labels[VideoQuality.dolbyVision.code], '杜比视界试看');
    expect(labels[VideoQuality.hdr.code], 'HDR试看');
    expect(labels[VideoQuality.high108060.code], '1080P60试看');
    expect(labels[VideoQuality.high1080plus.code], '1080P+试看');
    expect(labels[VideoQuality.high72060.code], '720P60试看');
    expect(labels[VideoQuality.high1080.code], VideoQuality.high1080.desc);
    expect(
      videoQualitySettingLabelFromCode(VideoQuality.super4K.code),
      '4K试看',
    );
  });

  test('detects default trial quality advertised without a stream', () {
    final playUrl = PlayUrlModel(
      acceptQuality: [VideoQuality.super4K.code, VideoQuality.high1080.code],
      supportFormats: [
        FormatItem(
          quality: VideoQuality.super4K.code,
          newDesc: VideoQuality.super4K.desc,
        ),
        FormatItem(
          quality: VideoQuality.high1080.code,
          newDesc: VideoQuality.high1080.desc,
        ),
      ],
      dash: Dash(
        video: [
          VideoItem(
            id: VideoQuality.high1080.code,
            quality: VideoQuality.high1080,
          ),
        ],
      ),
    );

    expect(
      shouldLoadTrialVideoQuality(playUrl, VideoQuality.super4K.code),
      isTrue,
    );
    expect(
      shouldLoadTrialVideoQuality(playUrl, VideoQuality.high1080.code),
      isFalse,
    );
    expect(shouldLoadTrialVideoQuality(playUrl, null), isFalse);
  });
}
