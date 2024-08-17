import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

/// Returns the metadata at a given version
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateGetApiAt
    extends SubstrateRPCRequest<String, (MetadataApi, String)?> {
  const SubstrateGetApiAt(this.version);
  final int version;

  @override
  String get rpcMethod => SubstrateRPCMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    final val = BytesUtils.toHexString(LayoutConst.u32().serialize(version),
        prefix: "0x");
    return ["Metadata_metadata_at_version", val, null];
  }

  @override
  (MetadataApi, String)? onResonse(String result) {
    try {
      final toBytes = BytesUtils.fromHexString(result);
      final decode =
          LayoutConst.optional(LayoutConst.bytes()).deserialize(toBytes).value;
      if (decode == null) return null;
      final api = VersionedMetadata.fromBytes(decode).toApi();
      return (api, BytesUtils.toHexString(decode));
    } catch (e) {
      return null;
    }
  }
}

class SubstrateGetStateApi
    extends SubstrateRPCRequest<String, (MetadataApi, String)?> {
  const SubstrateGetStateApi({this.atBlockHash});

  final String? atBlockHash;

  @override
  String get rpcMethod => SubstrateRPCMethods.getMetadata.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }

  @override
  (MetadataApi, String)? onResonse(String result) {
    try {
      final toBytes = BytesUtils.fromHexString(result);
      final versioned = VersionedMetadata.fromBytes(toBytes);
      return (versioned.toApi(), result);
    } catch (e) {
      return null;
    }
  }
}
