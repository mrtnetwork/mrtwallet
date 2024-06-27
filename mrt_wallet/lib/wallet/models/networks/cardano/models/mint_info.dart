import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/networks/cardano/cardano.dart';
import 'package:on_chain/ada/ada.dart';

class ADAMintInfo {
  final Assets assets;
  final NativeScript script;
  final ADAAddress owner;
  final List<int> pubKeyBytes;
  PolicyID toPolicyId() {
    return PolicyID(script.toHash().data);
  }

  ADAMintInfo(
      {required this.assets,
      required this.script,
      required this.owner,
      required List<int> pubKeyBytes})
      : pubKeyBytes = BytesUtils.toBytes(pubKeyBytes, unmodifiable: true);

  late final UtxoAssets toUtxoAssets = _toUtxoAssets();
  late final UtxoMultiAsset toMultiAsset = _toMultiAsset();
  UtxoAssets _toUtxoAssets() {
    final Map<AssetName, IntegerBalance> multiAssets = {};
    for (final i in assets.assets.entries) {
      multiAssets[i.key] = IntegerBalance(i.value, 0);
    }
    return UtxoAssets(multiAssets);
  }

  UtxoMultiAsset _toMultiAsset() {
    return UtxoMultiAsset({toPolicyId(): _toUtxoAssets()});
  }

  ADAMinsBuilder toMintBuilder() {
    return ADAMinsBuilder(
        pubKeyBytes: pubKeyBytes, mintingAssets: assets, owner: owner);
  }
}
