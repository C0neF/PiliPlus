import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:flutter/foundation.dart';

class PlayUrlMergeSource {
  const PlayUrlMergeSource({
    required this.load,
    this.debugLabel,
    this.requiresAppMediaHeaders = false,
  });

  final Future<LoadingState<PlayUrlModel>> Function() load;
  final String? debugLabel;
  final bool requiresAppMediaHeaders;
}

class PlayUrlMergeResult {
  const PlayUrlMergeResult({
    required this.success,
    this.requiresAppMediaHeaders = false,
  });

  final bool success;
  final bool requiresAppMediaHeaders;
}

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

Future<PlayUrlMergeResult> mergePlayUrlDashStreamsFromSources({
  required PlayUrlModel current,
  required int quality,
  required Iterable<PlayUrlMergeSource> sources,
}) async {
  for (final source in sources) {
    final result = await source.load();
    if (result case Success(:final response)) {
      if (kDebugMode) {
        final videos =
            response.dash?.video
                ?.map(
                  (item) =>
                      '${item.quality.code}:${item.width}x${item.height}:${item.codecs}',
                )
                .join(',') ??
            'none';
        debugPrint(
          '[trial-merge] ${source.debugLabel ?? 'source'} q=$quality videos=$videos',
        );
      }
      final merged = mergePlayUrlDashStreams(
        current: current,
        incoming: response,
        quality: quality,
      );
      if (merged) {
        return PlayUrlMergeResult(
          success: true,
          requiresAppMediaHeaders: source.requiresAppMediaHeaders,
        );
      }
    }
  }

  return const PlayUrlMergeResult(success: false);
}
