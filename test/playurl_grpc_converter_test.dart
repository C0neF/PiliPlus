import 'package:PiliPlus/grpc/bilibili/app/playurl/v1.pb.dart' as grpc;
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/utils/playurl_grpc_converter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  test('converts VIP trial dash streams into playable video items', () {
    final reply = grpc.PlayViewReply(
      videoInfo: grpc.VideoInfo(
        quality: VideoQuality.super4K.code,
        timelength: Int64(1000),
        streamList: [
          grpc.Stream(
            streamInfo: grpc.StreamInfo(
              quality: VideoQuality.super4K.code,
              format: 'flv',
              newDescription: '4K 超高清',
              displayDesc: '4K',
              needVip: true,
              vipFree: false,
            ),
            dashVideo: grpc.DashVideo(
              baseUrl: 'https://example.com/4k.m4s',
              backupUrl: ['https://example.com/4k-backup.m4s'],
              bandwidth: 1000,
              codecid: 7,
              width: 3840,
              height: 2160,
              frameRate: '60.000',
            ),
          ),
        ],
        dashAudio: [
          grpc.DashItem(
            id: 30280,
            baseUrl: 'https://example.com/audio.m4s',
            backupUrl: ['https://example.com/audio-backup.m4s'],
            bandwidth: 128000,
            codecid: 0,
          ),
        ],
      ),
    );

    final model = playViewReplyToPlayUrlModel(reply);

    expect(model.quality, VideoQuality.super4K.code);
    expect(model.timeLength, 1000);
    expect(model.supportFormats?.single.quality, VideoQuality.super4K.code);
    expect(model.supportFormats?.single.newDesc, '4K 超高清');
    expect(model.dash?.video?.single.id, VideoQuality.super4K.code);
    expect(model.dash?.video?.single.quality, VideoQuality.super4K);
    expect(model.dash?.video?.single.baseUrl, 'https://example.com/4k.m4s');
    expect(model.dash?.video?.single.backupUrl, [
      'https://example.com/4k-backup.m4s',
    ]);
    expect(model.dash?.video?.single.codecs, 'avc1');
    expect(model.dash?.audio?.single.id, 30280);
  });

  test('uses requested trial quality when reply selects that quality', () {
    final reply = grpc.PlayViewReply(
      videoInfo: grpc.VideoInfo(
        quality: VideoQuality.high108060.code,
        timelength: Int64(1000),
        streamList: [
          grpc.Stream(
            streamInfo: grpc.StreamInfo(
              quality: VideoQuality.high1080.code,
              format: 'flv',
              newDescription: '1080P 高帧率',
              displayDesc: '1080P',
              needVip: true,
              vipFree: false,
            ),
            dashVideo: grpc.DashVideo(
              baseUrl: 'https://example.com/1080p60.m4s',
              bandwidth: 1000,
              codecid: 7,
              width: 1920,
              height: 1080,
              frameRate: '60.000',
            ),
          ),
        ],
      ),
    );

    final model = playViewReplyToPlayUrlModel(
      reply,
      requestedQuality: VideoQuality.high108060.code,
    );

    expect(model.supportFormats?.single.quality, VideoQuality.high108060.code);
    expect(model.acceptQuality, [VideoQuality.high108060.code]);
    expect(model.dash?.video?.single.id, VideoQuality.high108060.code);
    expect(model.dash?.video?.single.quality, VideoQuality.high108060);
  });
}
