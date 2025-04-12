import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/networks/ethereum/models/eip712_domain.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:on_chain/solidity/solidity.dart';

class Web3EthreumTypdedData extends Web3EthereumRequestParam<String> {
  final EIP712Base typedData;
  BigInt? get chainId => domain?.chainId;
  final EIP712Domain? domain;
  @override
  final Web3EthereumChainAccount account;
  Web3EthreumTypdedData._(
      {required this.account, required this.typedData, this.domain});

  late final Map<String, dynamic> typedDataJson = typedData.toJson();

  factory Web3EthreumTypdedData(
      EIP712Base typedData, Web3EthereumChainAccount account) {
    EIP712Domain? domain;
    if (typedData.version != EIP712Version.v1) {
      domain = EIP712Domain.fromJson((typedData as Eip712TypedData).domain);
    }
    return Web3EthreumTypdedData._(
        account: account, typedData: typedData, domain: domain);
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
    return Web3EthreumTypdedData._(
        account: Web3EthereumChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
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
          account.toCbor(),
          CborStringValue(StringUtils.fromJson(typedData.toJson())),
          chainId
        ]),
        type.tag);
  }

  late String content = StringUtils.fromJson(typedData.toJson());

  @override
  Web3EthereumRequest<String, Web3EthreumTypdedData> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final EthereumChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3EthereumRequest<String, Web3EthreumTypdedData>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
