import 'package:PiliPlus/grpc/bilibili/app/playerunite/v1.pb.dart' as unite;
import 'package:PiliPlus/grpc/bilibili/app/playurl/v1.pb.dart' as playurl;
import 'package:PiliPlus/grpc/bilibili/playershared.pb.dart' as shared;
import 'package:PiliPlus/grpc/grpc_req.dart';
import 'package:PiliPlus/grpc/url.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/grpc_headers.dart';
import 'package:PiliPlus/utils/playurl_grpc_converter.dart';
import 'package:fixnum/fixnum.dart';

abstract final class VideoGrpc {
  static Future<LoadingState<PlayUrlModel>> playView({
    required int aid,
    required int cid,
    required int qn,
    bool voiceBalance = false,
  }) async {
    final result = await GrpcReq.request(
      GrpcUrl.playView,
      playurl.PlayViewReq(
        aid: Int64(aid),
        cid: Int64(cid),
        qn: Int64(qn),
        fnver: 0,
        fnval: 4048,
        download: 0,
        forceHost: 2,
        fourk: true,
        preferCodecType: playurl.CodeType.CODE265,
        voiceBalance: voiceBalance ? Int64.ONE : null,
      ),
      playurl.PlayViewReply.fromBuffer,
      headers: GrpcHeaders.newPinkHeaders(Accounts.video.accessKey),
      skipAccount: true,
    );

    return switch (result) {
      Success(:final response) => Success(
        playViewReplyToPlayUrlModel(response, requestedQuality: qn),
      ),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
      _ => LoadingState.loading(),
    };
  }

  static Future<LoadingState<PlayUrlModel>> playViewUniteTrial({
    required int aid,
    required String bvid,
    required int cid,
    required int qn,
    bool voiceBalance = false,
  }) async {
    final result = await GrpcReq.request(
      GrpcUrl.playViewUnite,
      unite.PlayViewUniteReq(
        bvid: bvid,
        spmid: 'united.player-video-detail.0.0',
        fromSpmid: '0.0.0.0',
        extraContent: const {
          'is_need_view_info': 'true',
          'security_level': 'LEVEL_L1',
        },
        vod: shared.VideoVod(
          aid: Int64(aid),
          cid: Int64(cid),
          qn: Int64(qn),
          fnver: 0,
          fnval: 4048,
          download: 0,
          forceHost: 2,
          fourk: true,
          preferCodecType: shared.CodeType.CODE265,
          voiceBalance: voiceBalance ? Int64.ONE : null,
          isNeedTrial: true,
        ),
      ),
      unite.PlayViewUniteReply.fromBuffer,
      headers: GrpcHeaders.newPinkHeaders(Accounts.video.accessKey),
      skipAccount: true,
    );

    return switch (result) {
      Success(:final response) when response.hasVodInfo() => Success(
        vodInfoToPlayUrlModel(response.vodInfo, requestedQuality: qn),
      ),
      Success() => const Error('PlayViewUnite response has no vodInfo'),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
      _ => LoadingState.loading(),
    };
  }
}
