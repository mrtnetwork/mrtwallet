import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

import 'metadata_fields.dart';

class SubstrateOutputWithBalance {
  SubstrateOutputWithBalance(
      {required this.address, required WalletSubstrateNetwork network})
      : balance = IntegerBalance.zero(network.coinParam.decimal);

  final IntegerBalance balance;
  final ReceiptAddress<BaseSubstrateAddress> address;

  bool get hasAmount => !balance.isZero;

  void updateBalance(BigInt val) {
    balance.updateBalance(val);
  }

  SubstrateDefaultTransfer toMessage() {
    assert(!balance.balance.isNegative, "Invalid transfer amount.");
    return SubstrateDefaultTransfer(
        address: address.networkAddress, value: balance.balance);
  }
}
