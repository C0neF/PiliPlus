import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/video/play/url.dart';

class VideoQualityMenuEntry {
  const VideoQualityMenuEntry({
    required this.quality,
    required this.label,
    required this.enabled,
    required this.popupValue,
    this.format,
    this.isTrial = false,
  });

  final int quality;
  final String label;
  final bool enabled;
  final int popupValue;
  final String? format;
  final bool isTrial;
}

const trialVideoQualities = [
  VideoQuality.hdrVivid,
  VideoQuality.super8k,
  VideoQuality.dolbyVision,
  VideoQuality.hdr,
  VideoQuality.super4K,
  VideoQuality.high108060,
  VideoQuality.high1080plus,
  VideoQuality.high72060,
];

bool isTrialVideoQuality(int quality) =>
    trialVideoQualities.any((item) => item.code == quality);

String trialVideoQualityLabel(VideoQuality quality) {
  return switch (quality) {
    VideoQuality.dolbyVision => '杜比视界试看',
    VideoQuality.super4K => '4K试看',
    VideoQuality.high108060 => '1080P60试看',
    VideoQuality.high1080plus => '1080P+试看',
    _ => '${quality.shortDesc}试看',
  };
}

String videoQualitySettingLabel(VideoQuality quality) {
  return isTrialVideoQuality(quality.code)
      ? trialVideoQualityLabel(quality)
      : quality.desc;
}

String videoQualitySettingLabelFromCode(int code) {
  return videoQualitySettingLabel(VideoQuality.fromCode(code));
}

List<(int, String)> buildVideoQualitySettingOptions() {
  return VideoQuality.values
      .map((quality) => (quality.code, videoQualitySettingLabel(quality)))
      .toList();
}

bool shouldLoadTrialVideoQuality(PlayUrlModel videoInfo, int? quality) {
  if (quality == null || !isTrialVideoQuality(quality)) {
    return false;
  }
  final hasCurrentStream =
      videoInfo.dash?.video?.any((item) => item.quality.code == quality) ??
      false;
  if (hasCurrentStream) {
    return false;
  }
  return videoInfo.supportFormats?.any((item) => item.quality == quality) ==
          true ||
      (videoInfo.acceptQuality?.contains(quality) ?? false);
}

List<VideoQualityMenuEntry> buildVideoQualityMenuEntries(
  PlayUrlModel videoInfo,
) {
  final formats = videoInfo.supportFormats ?? const <FormatItem>[];
  final playableQualities =
      videoInfo.dash?.video?.map((item) => item.quality.code).toSet() ??
      const <int>{};
  final entries = <VideoQualityMenuEntry>[];
  final trialFormatQualities = <int>{};

  for (final item in formats) {
    final quality = item.quality;
    if (quality == null) {
      continue;
    }
    final enabled = playableQualities.contains(quality);
    entries.add(
      VideoQualityMenuEntry(
        quality: quality,
        label: item.newDesc ?? item.displayDesc ?? item.format ?? '$quality',
        enabled: enabled,
        popupValue: quality,
        format: item.format,
      ),
    );

    if (isTrialVideoQuality(quality)) {
      final trialQuality = VideoQuality.fromCode(quality);
      trialFormatQualities.add(quality);
      entries.add(
        VideoQualityMenuEntry(
          quality: quality,
          label: trialVideoQualityLabel(trialQuality),
          enabled: true,
          popupValue: -quality,
          format: item.format,
          isTrial: true,
        ),
      );
    }
  }

  final fallbackTrialEntries = <VideoQualityMenuEntry>[];
  for (final quality in trialVideoQualities) {
    if (!trialFormatQualities.contains(quality.code) &&
        (videoInfo.acceptQuality?.contains(quality.code) ?? false)) {
      fallbackTrialEntries.add(
        VideoQualityMenuEntry(
          quality: quality.code,
          label: trialVideoQualityLabel(quality),
          enabled: true,
          popupValue: -quality.code,
          format: quality.shortDesc,
          isTrial: true,
        ),
      );
    }
  }
  entries.insertAll(0, fallbackTrialEntries);

  return entries;
}
