import 'package:PiliPlus/grpc/bilibili/app/playurl/v1.pb.dart' as grpc;
import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/video/play/url.dart';

PlayUrlModel playViewReplyToPlayUrlModel(
  grpc.PlayViewReply reply, {
  int? requestedQuality,
}) {
  final videoInfo = reply.videoInfo;
  final streams = videoInfo.streamList;
  final supportFormats = <FormatItem>[];
  final acceptQuality = <int>[];
  final acceptDesc = <String>[];
  final seenQuality = <int>{};

  for (final stream in streams) {
    if (!stream.hasStreamInfo()) {
      continue;
    }
    final streamInfo = stream.streamInfo;
    final quality = _effectiveStreamQuality(
      responseQuality: videoInfo.quality,
      streamQuality: streamInfo.quality,
      requestedQuality: requestedQuality,
    );
    if (!seenQuality.add(quality)) {
      continue;
    }
    final desc = streamInfo.newDescription.isNotEmpty
        ? streamInfo.newDescription
        : streamInfo.description;
    acceptQuality.add(quality);
    acceptDesc.add(desc);
    supportFormats.add(
      FormatItem(
        quality: quality,
        format: streamInfo.format,
        newDesc: desc,
        displayDesc: streamInfo.displayDesc,
        codecs: stream.hasDashVideo()
            ? [_codecFromCodecid(stream.dashVideo.codecid)]
            : null,
      ),
    );
  }

  final videoItems = <VideoItem>[];
  for (final stream in streams) {
    if (!stream.hasStreamInfo() || !stream.hasDashVideo()) {
      continue;
    }
    final dashVideo = stream.dashVideo;
    if (dashVideo.baseUrl.isEmpty) {
      continue;
    }
    final quality = _videoQualityFromCode(
      _effectiveStreamQuality(
        responseQuality: videoInfo.quality,
        streamQuality: stream.streamInfo.quality,
        requestedQuality: requestedQuality,
      ),
    );
    if (quality == null) {
      continue;
    }
    videoItems.add(
      VideoItem(
        id: quality.code,
        baseUrl: dashVideo.baseUrl,
        backupUrl: dashVideo.backupUrl.toList(),
        bandWidth: dashVideo.bandwidth,
        codecs: _codecFromCodecid(dashVideo.codecid),
        width: dashVideo.width,
        height: dashVideo.height,
        frameRate: dashVideo.frameRate,
        codecid: dashVideo.codecid,
        quality: quality,
      ),
    );
  }

  final audioItems = <AudioItem>[];
  for (final dashAudio in videoInfo.dashAudio) {
    if (dashAudio.baseUrl.isEmpty) {
      continue;
    }
    audioItems.add(
      AudioItem()
        ..id = dashAudio.id
        ..baseUrl = dashAudio.baseUrl
        ..backupUrl = dashAudio.backupUrl.toList()
        ..bandWidth = dashAudio.bandwidth
        ..codecs = _codecFromCodecid(dashAudio.codecid)
        ..frameRate = dashAudio.frameRate
        ..codecid = dashAudio.codecid
        ..quality = _audioDescFromCode(dashAudio.id),
    );
  }

  return PlayUrlModel(
    quality: videoInfo.quality,
    format: videoInfo.format,
    timeLength: videoInfo.timelength.toInt(),
    acceptFormat: supportFormats.map((item) => item.format).join(','),
    acceptDesc: acceptDesc,
    acceptQuality: acceptQuality,
    videoCodecid: videoInfo.videoCodecid,
    supportFormats: supportFormats,
    dash: Dash(
      video: videoItems.isEmpty ? null : videoItems,
      audio: audioItems.isEmpty ? null : audioItems,
    ),
  );
}

int _effectiveStreamQuality({
  required int responseQuality,
  required int streamQuality,
  int? requestedQuality,
}) {
  if (requestedQuality != null && responseQuality == requestedQuality) {
    return requestedQuality;
  }
  return streamQuality;
}

String _codecFromCodecid(int codecid) => switch (codecid) {
  12 => 'hev1',
  13 => 'av01',
  _ => 'avc1',
};

VideoQuality? _videoQualityFromCode(int code) {
  try {
    return VideoQuality.fromCode(code);
  } catch (_) {
    return null;
  }
}

String _audioDescFromCode(int code) {
  try {
    return AudioQuality.fromCode(code).desc;
  } catch (_) {
    return code.toString();
  }
}
