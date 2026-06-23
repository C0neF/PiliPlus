// Minimal hand-written subset of bilibili.app.playerunite.v1 used by PlayViewUnite.
// Field numbers were verified against BiliRoamingX's grpc_apis.jar.

import 'dart:core' as $core;

import 'package:PiliPlus/grpc/bilibili/playershared.pb.dart' as shared;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class PlayViewUniteReq extends $pb.GeneratedMessage {
  factory PlayViewUniteReq({
    shared.VideoVod? vod,
    $core.String? spmid,
    $core.String? fromSpmid,
    $core.Map<$core.String, $core.String>? extraContent,
    $core.String? bvid,
    $core.String? adExtra,
  }) {
    final result = create();
    if (vod != null) result.vod = vod;
    if (spmid != null) result.spmid = spmid;
    if (fromSpmid != null) result.fromSpmid = fromSpmid;
    if (extraContent != null) result.extraContent.addAll(extraContent);
    if (bvid != null) result.bvid = bvid;
    if (adExtra != null) result.adExtra = adExtra;
    return result;
  }

  PlayViewUniteReq._();

  factory PlayViewUniteReq.fromBuffer(
    $core.List<$core.int> data, [
    $pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY,
  ]) => create()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          'PlayViewUniteReq',
          package: const $pb.PackageName('bilibili.app.playerunite.v1'),
          createEmptyInstance: create,
        )
        ..aOM<shared.VideoVod>(1, 'vod', subBuilder: shared.VideoVod.create)
        ..aOS(2, 'spmid')
        ..aOS(3, 'fromSpmid')
        ..m<$core.String, $core.String>(
          4,
          'extraContent',
          entryClassName: 'PlayViewUniteReq.ExtraContentEntry',
          keyFieldType: $pb.PbFieldType.OS,
          valueFieldType: $pb.PbFieldType.OS,
          packageName: const $pb.PackageName('bilibili.app.playerunite.v1'),
        )
        ..aOS(5, 'bvid')
        ..aOS(6, 'adExtra')
        ..hasRequiredFields = false;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  @$core.override
  PlayViewUniteReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  @$core.override
  PlayViewUniteReq copyWith(void Function(PlayViewUniteReq) updates) =>
      super.copyWith((message) => updates(message as PlayViewUniteReq))
          as PlayViewUniteReq;

  @$core.pragma('dart2js:noInline')
  static PlayViewUniteReq create() => PlayViewUniteReq._();
  @$core.override
  PlayViewUniteReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PlayViewUniteReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlayViewUniteReq>(create);
  static PlayViewUniteReq? _defaultInstance;

  @$pb.TagNumber(1)
  shared.VideoVod get vod => $_getN(0);
  @$pb.TagNumber(1)
  set vod(shared.VideoVod value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasVod() => $_has(0);
  @$pb.TagNumber(1)
  void clearVod() => $_clearField(1);
  @$pb.TagNumber(1)
  shared.VideoVod ensureVod() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get spmid => $_getSZ(1);
  @$pb.TagNumber(2)
  set spmid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpmid() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpmid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fromSpmid => $_getSZ(2);
  @$pb.TagNumber(3)
  set fromSpmid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromSpmid() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromSpmid() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.String> get extraContent => $_getMap(3);

  @$pb.TagNumber(5)
  $core.String get bvid => $_getSZ(4);
  @$pb.TagNumber(5)
  set bvid($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBvid() => $_has(4);
  @$pb.TagNumber(5)
  void clearBvid() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get adExtra => $_getSZ(5);
  @$pb.TagNumber(6)
  set adExtra($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAdExtra() => $_has(5);
  @$pb.TagNumber(6)
  void clearAdExtra() => $_clearField(6);
}

class PlayViewUniteReply extends $pb.GeneratedMessage {
  factory PlayViewUniteReply({
    shared.VodInfo? vodInfo,
  }) {
    final result = create();
    if (vodInfo != null) result.vodInfo = vodInfo;
    return result;
  }

  PlayViewUniteReply._();

  factory PlayViewUniteReply.fromBuffer(
    $core.List<$core.int> data, [
    $pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY,
  ]) => create()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(
          'PlayViewUniteReply',
          package: const $pb.PackageName('bilibili.app.playerunite.v1'),
          createEmptyInstance: create,
        )
        ..aOM<shared.VodInfo>(1, 'vodInfo', subBuilder: shared.VodInfo.create)
        ..hasRequiredFields = false;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  @$core.override
  PlayViewUniteReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  @$core.override
  PlayViewUniteReply copyWith(void Function(PlayViewUniteReply) updates) =>
      super.copyWith((message) => updates(message as PlayViewUniteReply))
          as PlayViewUniteReply;

  @$core.pragma('dart2js:noInline')
  static PlayViewUniteReply create() => PlayViewUniteReply._();
  @$core.override
  PlayViewUniteReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PlayViewUniteReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlayViewUniteReply>(create);
  static PlayViewUniteReply? _defaultInstance;

  @$pb.TagNumber(1)
  shared.VodInfo get vodInfo => $_getN(0);
  @$pb.TagNumber(1)
  set vodInfo(shared.VodInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasVodInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearVodInfo() => $_clearField(1);
  @$pb.TagNumber(1)
  shared.VodInfo ensureVodInfo() => $_ensure(0);
}
