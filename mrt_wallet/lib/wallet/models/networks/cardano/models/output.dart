import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:on_chain/on_chain.dart';
import 'utxo_multi_asset.dart';

class CardanoOutputWithBalance {
  CardanoOutputWithBalance._(
      {required ReceiptAddress<ADAAddress> address,
      required WalletCardanoNetwork network,
      UtxoMultiAsset? asset})
      : balance = IntegerBalance.zero(network.coinParam.decimal),
        _asset = asset ?? UtxoMultiAsset({}),
        _address = address,
        minAdaValue = IntegerBalance.zero(network.coinParam.decimal);
  factory CardanoOutputWithBalance(
      {required ReceiptAddress<ADAAddress> address,
      required WalletCardanoNetwork network}) {
    final output =
        CardanoOutputWithBalance._(address: address, network: network);
    output._checkOutput();
    return output;
  }

  final IntegerBalance balance;
  final IntegerBalance minAdaValue;
  ReceiptAddress<ADAAddress> _address;
  ReceiptAddress<ADAAddress> get address => _address;
  UtxoMultiAsset _asset;
  UtxoMultiAsset get asset => _asset;
  bool get hasAssets => asset.assets.isNotEmpty;
  bool get hasAmount => !balance.isZero;
  bool get addressEraSupported =>
      address.networkAddress.addressType != ADAAddressType.byron;
  bool get isRewardAddress =>
      _address.networkAddress.addressType == ADAAddressType.reward;
  bool _isReady = false;
  bool get isReady => _isReady;
  bool _minAdaRequired = false;
  bool get minAdaRequired => _minAdaRequired;

  void _checkOutput() {
    _minAdaRequired = hasAmount && balance.balance < minAdaValue.balance;
    _isReady = hasAmount && !isRewardAddress && !minAdaRequired;
  }

  void setAsset(UtxoMultiAsset? updateAsset) {
    _asset = updateAsset ?? UtxoMultiAsset.empty;
    if (!hasAssets) {
      updateBalance(BigInt.zero);
      return;
    }
    _checkOutput();
  }

  void setAddress(ReceiptAddress<ADAAddress>? updateAddress,
      {int? coinsPerUtxoSize}) {
    _address = updateAddress ?? _address;
    if (coinsPerUtxoSize != null) {
      minAdaValue.updateBalance(minValue(coinsPerUtxoSize));
    }
    _checkOutput();
  }

  void updateBalance(BigInt val, {int? coinsPerUtxoSize}) {
    balance.updateBalance(val);
    if (coinsPerUtxoSize != null) {
      minAdaValue.updateBalance(minValue(coinsPerUtxoSize));
    }
    _checkOutput();
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