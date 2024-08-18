import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/crypto/utils/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateOutputWithBalance {
  SubstrateOutputWithBalance(
      {required this.address, required WalletPolkadotNetwork network})
      : balance = IntegerBalance.zero(network.coinParam.decimal);

  final IntegerBalance balance;
  final ReceiptAddress<SubstrateAddress> address;

  bool get hasAmount => !balance.isZero;

  void updateBalance(BigInt val) {
    balance.updateBalance(val);
  }

  Map<String, dynamic> toMessage({bool usePallet = false}) {
    return SubstrateUtils.buildTransferStruct(
        destination: address.networkAddress,
        value: balance.balance,
        usePallet: usePallet);
  }
}
