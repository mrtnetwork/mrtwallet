import 'package:on_chain/solidity/contract/fragments.dart';
import 'package:on_chain/tron/tron.dart';

class TronRequestTriggerTRC20TransferContract
    extends TronRequest<ParsedSmartContractRequest, Map<String, dynamic>> {
  TronRequestTriggerTRC20TransferContract(
      {required this.ownerAddress,
      required this.contractAddress,
      required this.data,
      required this.fragment,
      this.callValue,
      this.callTokenValue,
      this.tokenID,
      this.visible = true});
  final BigInt? callValue;
  final BigInt? callTokenValue;
  final BigInt? tokenID;
  final TronAddress ownerAddress;

  final TronAddress contractAddress;

  final String data;

  @override
  final bool visible;
  final AbiFunctionFragment? fragment;

  @override
  TronHTTPMethods get method => TronHTTPMethods.triggerconstantcontract;

  @override
  Map<String, dynamic> toJson() {
    return {
      "owner_address": ownerAddress,
      "contract_address": contractAddress,
      "data": data,
      "visible": visible,
      "call_value": callValue,
      "call_token_value": callTokenValue,
      "token_id": tokenID
    };
  }

  @override
  ParsedSmartContractRequest onResonse(result) {
    return ParsedSmartContractRequest.fromJson(result, fragment);
  }
}

class TronRequestCreateContractEstimateEnergy
    extends TronRequest<ParsedSmartContractRequest, Map<String, dynamic>> {
  TronRequestCreateContractEstimateEnergy(
      {required this.data,
      required this.ownerAddress,
      this.callValue,
      this.callTokenValue,
      this.tokenID,
      this.visible = true});
  final BigInt? callValue;
  final BigInt? callTokenValue;
  final BigInt? tokenID;
  final TronAddress ownerAddress;
  final String data;

  @override
  final bool visible;

  @override
  TronHTTPMethods get method => TronHTTPMethods.triggerconstantcontract;

  @override
  Map<String, dynamic> toJson() {
    return {
      "owner_address": ownerAddress,
      "data": data,
      "visible": visible,
      "call_value": callValue,
      "call_token_value": callTokenValue,
      "token_id": tokenID
    };
  }

  @override
  ParsedSmartContractRequest onResonse(result) {
    return ParsedSmartContractRequest.fromJson(result, null);
  }
}
