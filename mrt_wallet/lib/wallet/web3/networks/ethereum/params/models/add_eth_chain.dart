import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/core/request.dart';

class Web3EthereumAddNewChain extends Web3EthereumRequestParam<String> {
  final BigInt newChainId;
  final String chainName;
  final String name;
  final String symbol;
  final List<String> rpcUrls;
  final List<String>? blockExplorerUrls;
  final List<String>? iconUrls;
  final int decimals;

  Web3EthereumAddNewChain._(
      {required this.newChainId,
      required this.chainName,
      required this.name,
      required this.symbol,
      required this.decimals,
      required List<String> rpcUrls,
      required List<String>? blockExplorerUrls,
      required List<String>? iconUrls})
      : rpcUrls = rpcUrls.imutable,
        blockExplorerUrls = blockExplorerUrls?.imutableAndNullOnEmpty,
        iconUrls = iconUrls?.imutableAndNullOnEmpty;
  factory Web3EthereumAddNewChain(
      {required BigInt newChainId,
      required String chainName,
      required String name,
      required String symbol,
      required int decimals,
      required List<String> rpcUrls,
      required List<String>? blockExplorerUrls,
      required List<String>? iconUrls}) {
    return Web3EthereumAddNewChain._(
        newChainId: newChainId,
        chainName: chainName,
        name: name,
        symbol: symbol,
        decimals: decimals,
        rpcUrls: rpcUrls,
        blockExplorerUrls:
            (blockExplorerUrls?.isEmpty ?? true) ? null : blockExplorerUrls,
        iconUrls: (iconUrls?.isEmpty ?? true) ? null : iconUrls);
  }

  factory Web3EthereumAddNewChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3EthereumAddNewChain(
        newChainId: values.elementAt(1),
        chainName: values.elementAt(2),
        name: values.elementAt(3),
        symbol: values.elementAt(4),
        rpcUrls: values.getElement<CborListValue>(5).cast<String>(),
        blockExplorerUrls: values.getElement<CborListValue?>(6)?.cast<String>(),
        iconUrls: values.getElement<CborListValue?>(7)?.cast<String>(),
        decimals: values.elementAt(8));
  }

  @override
  Web3EthereumRequestMethods get method =>
      Web3EthereumRequestMethods.addEthereumChain;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          newChainId,
          chainName,
          name,
          symbol,
          CborListValue.fixedLength(rpcUrls),
          blockExplorerUrls == null
              ? const CborNullValue()
              : CborListValue.fixedLength(blockExplorerUrls!),
          iconUrls == null
              ? const CborNullValue()
              : CborListValue.fixedLength(blockExplorerUrls!),
          decimals
        ]),
        type.tag);
  }

  @override
  Web3EthereumRequest<String, Web3EthereumAddNewChain> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final EthereumChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3EthereumRequest<String, Web3EthereumAddNewChain>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
