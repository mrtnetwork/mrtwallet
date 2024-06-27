import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

class CosmosOutputWithBalance {
  CosmosOutputWithBalance(
      {required this.address, required WalletCosmosNetwork network})
      : balance = IntegerBalance.zero(network.coinParam.decimal);

  final IntegerBalance balance;
  final ReceiptAddress<CosmosBaseAddress> address;

  bool get hasAmount => !balance.isZero;

  void updateBalance(BigInt val, {int? coinsPerUtxoSize}) {
    balance.updateBalance(val);
  }

  ServiceMessage toMessage(
      CosmosBaseAddress from, WalletCosmosNetwork network) {
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
