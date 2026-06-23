import 'package:PiliPlus/models/video/play/url.dart';

bool mergePlayUrlDashStreams({
  required PlayUrlModel current,
  required PlayUrlModel incoming,
  required int quality,
}) {
  final incomingVideos = incoming.dash?.video
      ?.where(
        (item) =>
            item.quality.code == quality && item.baseUrl?.isNotEmpty == true,
      )
      .toList();
  if (incomingVideos == null || incomingVideos.isEmpty) {
    return false;
  }

  final currentDash = current.dash ??= Dash();
  (currentDash.video ??= <VideoItem>[])
    ..removeWhere((item) => item.quality.code == quality)
    ..insertAll(0, incomingVideos);

  final incomingAudio = incoming.dash?.audio;
  if (incomingAudio != null && incomingAudio.isNotEmpty) {
    final currentAudio = currentDash.audio ??= <AudioItem>[];
    final incomingAudioIds = incomingAudio.map((item) => item.id).toSet();
    currentAudio
      ..removeWhere((item) => incomingAudioIds.contains(item.id))
      ..addAll(incomingAudio);
  }

  final incomingSupportFormats = incoming.supportFormats;
  if (incomingSupportFormats != null && incomingSupportFormats.isNotEmpty) {
    final currentSupportFormats = current.supportFormats ??= <FormatItem>[];
    final formatQualities = currentSupportFormats
        .map((item) => item.quality)
        .toSet();
    currentSupportFormats.addAll(
      incomingSupportFormats.where(
        (item) => item.quality == quality && formatQualities.add(item.quality),
      ),
    );
  }

  final incomingAcceptQuality = incoming.acceptQuality;
  if (incomingAcceptQuality != null && incomingAcceptQuality.isNotEmpty) {
    final currentAcceptQuality = current.acceptQuality ??= <int>[];
    if (!currentAcceptQuality.contains(quality) &&
        incomingAcceptQuality.contains(quality)) {
      currentAcceptQuality.add(quality);
    }
  }

  return true;
}
