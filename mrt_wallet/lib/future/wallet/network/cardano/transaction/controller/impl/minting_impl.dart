import 'package:mrt_wallet/future/wallet/network/cardano/transaction/controller/impl/transaction.dart';
import 'package:mrt_wallet/wallet/models/networks/cardano/cardano.dart';

mixin CardanoMintingImpl on CardanoTransactionImpl {
  List<ADAMintInfo> _mints = [];
  @override
  List<ADAMintInfo> get mints => _mints;

  void setupMint(ADAMintInfo? mint) {
    if (mint == null) return;
    _mints = List<ADAMintInfo>.unmodifiable([mint, ..._mints]);
    setTotalAssets(totalAssets + mint.toMultiAsset);
    calculateFee();
  }

  void removeMint(ADAMintInfo? mint) {
    if (!_mints.contains(mint)) return;
    _mints = List<ADAMintInfo>.unmodifiable(
        _mints.where((element) => element != mint));
    _cleanUpUsedMint(mint!);
  }

  void _cleanUpUsedMint(ADAMintInfo mint) {
    final mintingAsset = mint.toMultiAsset;
    setTotalAssets(totalAssets - mintingAsset);
    changeAssetOutput.updateAssets(changeAssetOutput.asset - mintingAsset);
    for (final i in receivers) {
      i.updateAssets(i.asset - mintingAsset);
    }
    calculateFee();
  }
}
