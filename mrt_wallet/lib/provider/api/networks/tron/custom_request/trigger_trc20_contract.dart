import 'package:mrt_wallet/app/utility/blockchin_utils/ethereum/ethereum_abi_constant.dart';
import 'package:on_chain/contract/fragments.dart';
import 'package:on_chain/tron/address/tron_address.dart';
import 'package:on_chain/tron/models/parsed_request/parsed_contract_request.dart';
import 'package:on_chain/tron/provider/core/request.dart';
import 'package:on_chain/tron/provider/methods/request_methods.dart';

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
  final AbiFunctionFragment _fragment = ETHAbiConstant.erc20Transfer;

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
