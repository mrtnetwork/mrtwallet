import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/provider/transaction_validator/tron/transaction_validator/vote_sr/create_witness.dart';

import 'package:on_chain/on_chain.dart';

class TronUpdateWitnessValidator extends TronCreateWitnessValidator {
  @override
  String get name => "update_witness";

  @override
  TransactionContractType get type =>
      TransactionContractType.witnessUpdateContract;

  @override
  TronBaseContract toContract({required ITronAddress owner}) {
    final validate = validateError(account: owner);
    if (validate != null) {
      throw WalletException(validate);
    }

    return WitnessUpdateContract(
        ownerAddress: owner.networkAddress,
        updateUrl: StringUtils.tryToBytes(url.value));
  }
}
