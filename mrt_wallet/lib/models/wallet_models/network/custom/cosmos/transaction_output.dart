import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';

class CosmosOutputWithBalance {
  CosmosOutputWithBalance(
      {required this.address, required APPCosmosNetwork network})
      : balance = NoneDecimalBalance.zero(network.coinParam.decimal);

  final NoneDecimalBalance balance;
  final ReceiptAddress<CosmosBaseAddress> address;

  bool get hasAmount => !balance.isZero;

  void updateBalance(BigInt val, {int? coinsPerUtxoSize}) {
    balance.updateBalance(val);
  }

  ServiceMessage toMessage(CosmosBaseAddress from, APPCosmosNetwork network) {
    if (network.coinParam.networkType != CosmosNetworkTypes.thorAndForked) {
      return MsgSend(
          fromAddress: from,
          toAddress: address.networkAddress,
          amount: [
            Coin(
                amount: balance.balance,
                denom: network.coinParam.mainCoin.denom)
          ]);
    }
    return ThorchainMsgSend(
        fromAddress: from,
        toAddress: address.networkAddress,
        amount: [
          Coin(amount: balance.balance, denom: network.coinParam.mainCoin.denom)
        ]);
  }
}
