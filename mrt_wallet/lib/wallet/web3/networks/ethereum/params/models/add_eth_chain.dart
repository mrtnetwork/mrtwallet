import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/validator/validator.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:mrt_wallet/crypto/utils/ethereum/utils.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';

class Web3EthereumAddNewChain extends Web3EthereumRequestParam<String> {
  final BigInt newChainId;
  final String chainName;
  final String name;
  final String symbol;
  final List<String> rpcUrls;
  final List<String>? blockExplorerUrls;
  final List<String>? iconUrls;
  final int decimals;

  Web3EthereumAddNewChain(
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
  Web3EthereumAddNewChain updateRpcUrl(List<String> rpcUrls) {
    return Web3EthereumAddNewChain(
        newChainId: newChainId,
        chainName: chainName,
        name: name,
        symbol: symbol,
        decimals: decimals,
        rpcUrls: rpcUrls,
        blockExplorerUrls: blockExplorerUrls,
        iconUrls: iconUrls);
  }

  factory Web3EthereumAddNewChain.fromJson(Map<String, dynamic> json) {
    const method = Web3EthereumRequestMethods.addEthereumChain;
    final Map<String, dynamic> nativeCurrency = Web3ValidatorUtils.parseMap(
        key: "nativeCurrency", method: method, json: json);
    final int? decimals = Web3ValidatorUtils.parseInt(
        key: "decimals", method: method, json: nativeCurrency);
    if (decimals != null && decimals != EthereumUtils.decimal) {
      throw Web3RequestExceptionConst.ethWrongDecimal;
    }
    return Web3EthereumAddNewChain(
      newChainId: Web3ValidatorUtils.parseBigInt(
          key: "chainId", method: method, json: json),
      chainName: Web3ValidatorUtils.parseString(
          key: "chainName", method: method, json: json),
      name: Web3ValidatorUtils.parseString(
          key: "name", method: method, json: nativeCurrency),
      symbol: Web3ValidatorUtils.parseString(
          key: "symbol", method: method, json: nativeCurrency),
      decimals: decimals ?? EthereumUtils.decimal,
      rpcUrls: Web3EthereumValidator.validateRpcs(
          Web3ValidatorUtils.parseList<List<String>, String>(
              key: "rpcUrls", method: method, json: json)),
      blockExplorerUrls: Web3ValidatorUtils.parseList<List<String>?, String>(
          key: "blockExplorerUrls", method: method, json: json),
      iconUrls: Web3ValidatorUtils.parseList<List<String>?, String>(
          key: "iconUrls", method: method, json: json),
    );
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
  Map<String, dynamic> toJson() {
    return {
      "chainId": newChainId.toRadix16,
      "chainName": chainName,
      "nativeCurrency": {"name": name, "symbol": symbol, "decimals": decimals},
      "rpcUrls": rpcUrls,
      "blockExplorerUrls": blockExplorerUrls,
      "iconUrls": iconUrls,
      "decimals": decimals
    };
  }

  @override
  ETHAddress? get account => null;

  @override
  Web3EthereumRequest<String, Web3EthereumAddNewChain> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required EthereumChain chain,
  }) {
    return Web3EthereumRequest<String, Web3EthereumAddNewChain>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }

  WalletEthereumNetwork toNewNetwork({int? inWalletNetworkId}) {
    return WalletEthereumNetwork(
        inWalletNetworkId ?? -1,
        EthereumNetworkParams(
            transactionExplorer: null,
            addressExplorer: null,
            token: Token(name: name, symbol: symbol, decimal: decimals),
            providers: rpcUrls
                .map((e) => EthereumAPIProvider(
                    serviceName: Uri.parse(e).host,
                    websiteUri: Uri.parse(e).host,
                    uri: e,
                    identifier: APIUtils.getProviderIdentifier(null)))
                .toList(),
            chainId: newChainId,
            supportEIP1559: false,
            mainnet: false));
  }
}
