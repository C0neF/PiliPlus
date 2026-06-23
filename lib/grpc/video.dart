import 'package:PiliPlus/grpc/bilibili/app/playurl/v1.pb.dart';
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
      PlayViewReq(
        aid: Int64(aid),
        cid: Int64(cid),
        qn: Int64(qn),
        fnver: 0,
        fnval: 4048,
        download: 0,
        forceHost: 2,
        fourk: true,
        preferCodecType: CodeType.CODE265,
        voiceBalance: voiceBalance ? Int64.ONE : null,
      ),
      PlayViewReply.fromBuffer,
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
}
