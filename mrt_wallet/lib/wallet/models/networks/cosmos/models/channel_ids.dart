import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class CosmosIBCChannelId with CborSerializable, Equatable {
  final String name;
  final String channelId;
  const CosmosIBCChannelId({required this.name, required this.channelId});
  factory CosmosIBCChannelId.deserialize(
      {List<int>? bytes, String? hex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: CborTagsConst.cosmosIbcChannelId);
    return CosmosIBCChannelId(
        name: values.elementAs(0), channelId: values.elementAs(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([name, channelId]),
        CborTagsConst.cosmosIbcChannelId);
  }

  @override
  List get variabels => [channelId, name];
}

class CosmosAccountIBCChannelIds with CborSerializable {
  List<CosmosIBCChannelId> _channelIds;
  List<CosmosIBCChannelId> get channelIds => _channelIds;
  CosmosAccountIBCChannelIds({List<CosmosIBCChannelId> channelIds = const []})
      : _channelIds = channelIds.immutable;
  factory CosmosAccountIBCChannelIds.deserialize(
      {List<int>? bytes, String? hex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: CborTagsConst.cosmosAccountChannelId);
    return CosmosAccountIBCChannelIds(
        channelIds: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => CosmosIBCChannelId.deserialize(object: e))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(_channelIds.map((e) => e.toCbor()).toList()),
        CborTagsConst.cosmosAccountChannelId);
  }

  void addChannel(CosmosIBCChannelId channel) {
    if (_channelIds.contains(channel)) return;
    _channelIds = [channel, ..._channelIds].toImutableList;
  }
}
