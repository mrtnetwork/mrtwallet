import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/networks/ethereum/models/eip712_domain.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/validator/validator.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/solidity.dart';

class Web3EthreumTypdedData extends Web3EthereumRequestParam<String> {
  final ETHAddress address;
  final EIP712Base typedData;
  BigInt? get chainId => domain?.chainId;
  final EIP712Domain? domain;
  Web3EthreumTypdedData(
      {required this.address, required this.typedData, this.domain});

  late final Map<String, dynamic> typedDataJson = typedData.toJson();

  factory Web3EthreumTypdedData.fromJson(Map<String, dynamic> json) {
    const method = Web3EthereumRequestMethods.typedData;

    final address = Web3ValidatorUtils.parseAddress(
        onParse: (c) => ETHAddress(c),
        key: "address",
        method: method,
        json: json);
    final typedData = Web3EthereumValidator.parseTypedData(
        data: json["typedData"], method: method);
    EIP712Domain? domain;
    if (typedData.version != EIP712Version.v1) {
      domain = EIP712Domain.fromJson((typedData as Eip712TypedData).domain);
    }
    return Web3EthreumTypdedData(
        address: address, typedData: typedData, domain: domain);
  }

  factory Web3EthreumTypdedData.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    final typedData =
        EIP712Base.fromJson(StringUtils.toJson(values.elementAt(2)));
    EIP712Domain? domain;
    if (typedData.version != EIP712Version.v1) {
      domain = EIP712Domain.fromJson((typedData as Eip712TypedData).domain);
    }
    return Web3EthreumTypdedData(
        address: ETHAddress(values.elementAt(1)),
        typedData: typedData,
        domain: domain);
  }

  @override
  Web3EthereumRequestMethods get method => Web3EthereumRequestMethods.typedData;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          address.address,
          CborStringValue(StringUtils.fromJson(typedData.toJson())),
          chainId
        ]),
        type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"address": address.address, "typedData": typedData.toJson()};
  }

  late String content = StringUtils.fromJson(typedData.toJson());

  @override
  Web3EthereumRequest<String, Web3EthreumTypdedData> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required EthereumChain chain,
  }) {
    return Web3EthereumRequest<String, Web3EthreumTypdedData>(
      // permission: authenticated.getChain(address: account, chain: chain) ??
      //     Web3EthereumChain.create(chainId: chain.network.coinParam.chainId),
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }

  @override
  ETHAddress? get account => address;
}
