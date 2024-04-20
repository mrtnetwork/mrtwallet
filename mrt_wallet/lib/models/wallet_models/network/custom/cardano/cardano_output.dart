import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:on_chain/on_chain.dart';
import 'utxo_multi_asset.dart';

class CardanoOutputWithBalance {
  CardanoOutputWithBalance(
      {required ReceiptAddress<ADAAddress> address,
      required APPCardanoNetwork network,
      UtxoMultiAsset? asset})
      : balance = NoneDecimalBalance.zero(network.coinParam.decimal),
        _asset = asset ?? UtxoMultiAsset({}),
        _address = address,
        minAdaValue = NoneDecimalBalance.zero(network.coinParam.decimal);

  final NoneDecimalBalance balance;
  final NoneDecimalBalance minAdaValue;
  ReceiptAddress<ADAAddress> _address;
  ReceiptAddress<ADAAddress> get address => _address;
  UtxoMultiAsset _asset;
  UtxoMultiAsset get asset => _asset;
  bool get hasAssets => asset.assets.isNotEmpty;
  bool get hasAmount => !balance.isZero;
  bool get isValid => balance.balance >= minAdaValue.balance;

  bool get minAdaRequired => hasAmount && !isValid;

  void setAsset(UtxoMultiAsset? updateAsset) {
    _asset = updateAsset ?? UtxoMultiAsset.empty;
  }

  void setAddress(ReceiptAddress<ADAAddress>? updateAddress) {
    _address = updateAddress ?? _address;
  }

  void updateBalance(BigInt val, {int? coinsPerUtxoSize}) {
    balance.updateBalance(val);
    if (coinsPerUtxoSize != null) {
      minAdaValue.updateBalance(minValue(coinsPerUtxoSize));
    }
  }

  TransactionOutput toOutput() {
    return TransactionOutput(
        address: address.networkAddress,
        amount: Value(
            coin: balance.balance,
            multiAsset: asset.hasAsset ? asset.toMultiAsset() : null));
  }

  BigInt minValue(int coinsPerUtxoSize) {
    final out = toOutput();
    return out
        .copyWith(amount: out.amount.copyWith(coin: maxU64))
        .minAda(coinsPerUtxoSize);
  }
}
