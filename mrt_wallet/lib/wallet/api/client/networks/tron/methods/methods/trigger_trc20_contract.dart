import 'package:mrt_wallet/wallet/constant/networks/ethereum.dart';
import 'package:on_chain/solidity/contract/fragments.dart';
import 'package:on_chain/tron/tron.dart';

class TronRequestTriggerTRC20TransferContract
    extends TVMRequestParam<ParsedSmartContractRequest, Map<String, dynamic>> {
  TronRequestTriggerTRC20TransferContract(
      {required this.ownerAddress,
      required this.contractAddress,
      required this.data,
      this.visible = true});

  final TronAddress ownerAddress;

  final TronAddress contractAddress;

  final String data;

  @override
  final bool visible;
  final AbiFunctionFragment _fragment = ETHConst.erc20Transfer;

  /// wallet/triggerconstantcontract
  @override
  TronHTTPMethods get method => TronHTTPMethods.triggerconstantcontract;

  @override
  Map<String, dynamic> toJson() {
    return {
      "owner_address": ownerAddress,
      "contract_address": contractAddress,
      "data": data,
      "visible": visible
    };
  }

  @override
  ParsedSmartContractRequest onResonse(result) {
    return ParsedSmartContractRequest.fromJson(result, _fragment);
  }
}
