import 'package:mrt_wallet/future/pages/wallet_pages/network/cardano_pages/transaction/controller/impl/transaction.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/cardano.dart';

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
    changeAssetOutput.setAsset(changeAssetOutput.asset - mintingAsset);
    for (final i in receivers) {
      i.setAsset(i.asset - mintingAsset);
    }
    calculateFee();
  }
}