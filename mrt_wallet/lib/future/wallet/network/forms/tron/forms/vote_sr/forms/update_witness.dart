import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/tron/addresses/tron.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/vote_sr/forms/create_witness.dart';
import 'package:on_chain/on_chain.dart';

class TronUpdateWitnessForm extends TronCreateWitnessForm {
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
